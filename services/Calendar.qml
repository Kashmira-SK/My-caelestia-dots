pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
import qs.utils
import Caelestia
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var events: []
    property var todos: []
    property bool loaded: false

    function dateKey(date) {
        if (typeof date === "string")
            return date

        const year = date.getFullYear()
        const month = String(date.getMonth() + 1).padStart(2, "0")
        const day = String(date.getDate()).padStart(2, "0")

        return `${year}-${month}-${day}`
    }

    function parseDate(key) {
        if (!key)
            return new Date()

        const parts = key.split("-")

        return new Date(
            Number(parts[0]),
            Number(parts[1]) - 1,
            Number(parts[2])
        )
    }

    function makeId(prefix) {
        return `${prefix}-${Date.now()}-${Math.floor(Math.random() * 100000)}`
    }

    function save() {
        if (!root.loaded)
            return

        saveTimer.restart()
    }

    function daysBetween(a, b) {
        const oneDay = 24 * 60 * 60 * 1000

        const utcA = Date.UTC(
            a.getFullYear(),
            a.getMonth(),
            a.getDate()
        )

        const utcB = Date.UTC(
            b.getFullYear(),
            b.getMonth(),
            b.getDate()
        )

        return Math.round(
            (utcB - utcA) / oneDay
        )
    }

    // events

    function recurrenceIndex(event, date) {
        if (!event.recurrence)
            return -1

        const start = parseDate(event.date)
        const frequency = event.recurrence.frequency

        const interval = Math.max(
            1,
            event.recurrence.interval || 1
        )

        if (date < start)
            return -1

        if (frequency === "daily") {
            const days = daysBetween(start, date)

            if (days % interval !== 0)
                return -1

            return Math.floor(
                days / interval
            )
        }

        if (frequency === "weekly") {
            const days = daysBetween(start, date)
            const step = 7 * interval

            if (days % step !== 0)
                return -1

            return Math.floor(
                days / step
            )
        }

        if (frequency === "monthly") {
            if (
                date.getDate()
                !== start.getDate()
            )
                return -1

            const months =
                (date.getFullYear()
                    - start.getFullYear()) * 12
                + date.getMonth()
                - start.getMonth()

            if (
                months < 0
                || months % interval !== 0
            )
                return -1

            return Math.floor(
                months / interval
            )
        }

        if (frequency === "yearly") {
            if (
                date.getMonth()
                    !== start.getMonth()
                || date.getDate()
                    !== start.getDate()
            )
                return -1

            const years =
                date.getFullYear()
                - start.getFullYear()

            if (
                years < 0
                || years % interval !== 0
            )
                return -1

            return Math.floor(
                years / interval
            )
        }

        return -1
    }

    function eventOccursOnDate(event, date) {
        const key = dateKey(date)

        if (event.date === key)
            return true

        if (!event.recurrence)
            return false

        const index = recurrenceIndex(
            event,
            date
        )

        if (index < 0)
            return false

        const count = Math.max(
            1,
            event.recurrence.count || 1
        )

        return index < count
    }

    function eventsForDate(date) {
        return root.events
            .filter(event =>
                eventOccursOnDate(
                    event,
                    date
                )
            )
            .slice()
            .sort((a, b) => {
                const timeA =
                    a.startTime
                    || a.time
                    || ""

                const timeB =
                    b.startTime
                    || b.time
                    || ""

                return timeA.localeCompare(
                    timeB
                )
            })
    }

    function addEvent(
        title,
        date,
        startTime,
        endTime,
        notes,
        recurrence
    ) {
        const event = {
            id: makeId("event"),
            title: title,
            date: dateKey(date),
            startTime: startTime || "",
            endTime: endTime || "",
            notes: notes || "",
            recurrence: recurrence || null
        }

        root.events = [
            ...root.events,
            event
        ]

        save()

        return event.id
    }

    function updateEvent(id, changes) {
        root.events = root.events.map(event => {
            if (event.id !== id)
                return event

            return Object.assign(
                {},
                event,
                changes
            )
        })

        save()
    }

    function removeEvent(id) {
        root.events = root.events.filter(
            event => event.id !== id
        )

        save()
    }

    // todos

    function todoDeadline(todo) {
        if (!todo.dueDate)
            return null

        const date = parseDate(todo.dueDate)

        if (todo.dueTime) {
            const parts = todo.dueTime.split(":")

            date.setHours(
                Number(parts[0]) || 0,
                Number(parts[1]) || 0,
                0,
                0
            )
        } else {
            // Date-only deadlines last until the end of the day.
            date.setHours(
                23,
                59,
                59,
                999
            )
        }

        return date
    }

    function todoIsOverdue(todo, now) {
        if (
            todo.completed
            || !todo.dueDate
        )
            return false

        const deadline =
            todoDeadline(todo)

        if (!deadline)
            return false

        return deadline.getTime()
            < (now || new Date()).getTime()
    }

    function priorityRank(priority) {
        if (priority === "hard")
            return 2

        if (priority === "medium")
            return 1

        return 0
    }

    function effectiveTodoPriority(todo, now) {
        if (todo.completed)
            return todo.priority || "small"

        if (!todo.dueDate)
            return todo.priority || "small"

        const current =
            now || new Date()

        if (todoIsOverdue(todo, current))
            return "overdue"

        const deadline =
            todoDeadline(todo)

        const hours =
            (
                deadline.getTime()
                - current.getTime()
            ) / 3600000

        const base =
            todo.priority || "small"

        if (hours <= 24)
            return "hard"

        if (
            hours <= 72
            && priorityRank(base)
                < priorityRank("medium")
        )
            return "medium"

        return base
    }

    function todoOccursOnDate(todo, date) {
        if (
            todo.completed
            || !todo.dueDate
        )
            return false

        return todo.dueDate
            === dateKey(date)
    }

    function todosForDate(date) {
        return root.todos
            .filter(todo =>
                todoOccursOnDate(
                    todo,
                    date
                )
            )
            .slice()
            .sort((a, b) => {
                const timeA =
                    a.dueTime || "23:59"

                const timeB =
                    b.dueTime || "23:59"

                return timeA.localeCompare(
                    timeB
                )
            })
    }

    function undatedTodos() {
        return root.todos.filter(todo =>
            !todo.completed
            && !todo.dueDate
        )
    }

    function overdueTodos() {
        const now = new Date()

        return root.todos
            .filter(todo =>
                todoIsOverdue(
                    todo,
                    now
                )
            )
            .slice()
            .sort((a, b) => {
                const aDate =
                    todoDeadline(a)

                const bDate =
                    todoDeadline(b)

                return aDate.getTime()
                    - bDate.getTime()
            })
    }

    function activeTodos() {
        return root.todos.filter(todo =>
            !todo.completed
        )
    }

    function completedTodos() {
        return root.todos.filter(todo =>
            todo.completed
        )
    }

    function hasItemsForDate(date) {
        return root.events.some(event =>
            eventOccursOnDate(
                event,
                date
            )
        ) || root.todos.some(todo =>
            todoOccursOnDate(
                todo,
                date
            )
        )
    }

    function hasEventsForDate(date) {
        return root.events.some(event =>
            eventOccursOnDate(
                event,
                date
            )
        )
    }

    function hasTodosForDate(date) {
        return root.todos.some(todo =>
            todoOccursOnDate(
                todo,
                date
            )
        )
    }

    function addTodo(
        title,
        priority,
        notes,
        dueDate,
        dueTime,
        recurrence
    ) {
        const todo = {
            id: makeId("todo"),
            title: title,
            priority: priority || "small",
            notes: notes || "",
            dueDate: dueDate
                ? dateKey(dueDate)
                : "",
            dueTime: dueTime || "",
            recurrence: recurrence || null,
            completed: false,
            completedAt: "",
            createdAt:
                new Date().toISOString()
        }

        root.todos = [
            ...root.todos,
            todo
        ]

        save()

        return todo.id
    }

    function updateTodo(id, changes) {
        root.todos = root.todos.map(todo => {
            if (todo.id !== id)
                return todo

            return Object.assign(
                {},
                todo,
                changes
            )
        })

        save()
    }

    function addTodoRecurrenceStep(
        date,
        recurrence
    ) {
        const interval = Math.max(
            1,
            recurrence.interval || 1
        )

        const result =
            new Date(
                date.getFullYear(),
                date.getMonth(),
                date.getDate()
            )

        if (
            recurrence.frequency
            === "daily"
        ) {
            result.setDate(
                result.getDate()
                + interval
            )

            return result
        }

        if (
            recurrence.frequency
            === "weekly"
        ) {
            result.setDate(
                result.getDate()
                + 7 * interval
            )

            return result
        }

        if (
            recurrence.frequency
            === "monthly"
        ) {
            const originalDay =
                result.getDate()

            const target =
                new Date(
                    result.getFullYear(),
                    result.getMonth()
                        + interval,
                    1
                )

            const lastDay =
                new Date(
                    target.getFullYear(),
                    target.getMonth() + 1,
                    0
                ).getDate()

            target.setDate(
                Math.min(
                    originalDay,
                    lastDay
                )
            )

            return target
        }

        if (
            recurrence.frequency
            === "yearly"
        ) {
            const month =
                result.getMonth()

            const day =
                result.getDate()

            const target =
                new Date(
                    result.getFullYear()
                        + interval,
                    month,
                    1
                )

            const lastDay =
                new Date(
                    target.getFullYear(),
                    month + 1,
                    0
                ).getDate()

            target.setDate(
                Math.min(
                    day,
                    lastDay
                )
            )

            return target
        }

        return result
    }

    function nextTodoDueDate(todo) {
        if (
            !todo.recurrence
            || !todo.dueDate
        )
            return ""

        let candidate =
            addTodoRecurrenceStep(
                parseDate(todo.dueDate),
                todo.recurrence
            )

        const today =
            new Date()

        today.setHours(
            0,
            0,
            0,
            0
        )

        // If several occurrences were missed,
        // move to the next future occurrence.
        let guard = 0

        while (
            candidate < today
            && guard < 10000
        ) {
            candidate =
                addTodoRecurrenceStep(
                    candidate,
                    todo.recurrence
                )

            guard++
        }

        return dateKey(candidate)
    }

    function finishTodo(id) {
        let changed = false

        root.todos = root.todos.map(todo => {
            if (todo.id !== id)
                return todo

            changed = true

            if (
                todo.recurrence
                && todo.dueDate
            ) {
                return Object.assign(
                    {},
                    todo,
                    {
                        dueDate:
                            nextTodoDueDate(
                                todo
                            ),
                        completed: false,
                        completedAt: ""
                    }
                )
            }

            return Object.assign(
                {},
                todo,
                {
                    completed: true,
                    completedAt:
                        new Date().toISOString()
                }
            )
        })

        if (changed)
            save()
    }

    function toggleTodo(id) {
        root.todos = root.todos.map(todo => {
            if (todo.id !== id)
                return todo

            const completed =
                !todo.completed

            return Object.assign(
                {},
                todo,
                {
                    completed: completed,
                    completedAt:
                        completed
                        ? new Date().toISOString()
                        : ""
                }
            )
        })

        save()
    }

    function removeTodo(id) {
        root.todos = root.todos.filter(
            todo => todo.id !== id
        )

        save()
    }

    Timer {
        id: saveTimer

        interval: 1000

        onTriggered: {
            storage.setText(
                JSON.stringify(
                    {
                        events:
                            root.events,
                        todos:
                            root.todos
                    },
                    null,
                    2
                )
            )
        }
    }

    FileView {
        id: storage

        path:
            `${Paths.state}/calendar.json`

        onLoaded: {
            try {
                const data =
                    JSON.parse(text())

                root.events =
                    Array.isArray(
                        data.events
                    )
                    ? data.events
                    : []

                root.todos =
                    Array.isArray(
                        data.todos
                    )
                    ? data.todos.map(todo =>
                        Object.assign(
                            {
                                title: "",
                                priority:
                                    "small",
                                notes: "",
                                dueDate: "",
                                dueTime: "",
                                recurrence:
                                    null,
                                completed:
                                    false,
                                completedAt:
                                    "",
                                createdAt:
                                    ""
                            },
                            todo
                        )
                    )
                    : []
            } catch (e) {
                root.events = []
                root.todos = []
            }

            root.loaded = true
        }

        onLoadFailed: err => {
            if (
                err
                === FileViewError.FileNotFound
            ) {
                root.events = []
                root.todos = []
                root.loaded = true

                setText(
                    JSON.stringify(
                        {
                            events: [],
                            todos: []
                        },
                        null,
                        2
                    )
                )
            }
        }

        onSaveFailed: err => {
            console.log(
                "Calendar save failed:",
                FileViewError.toString(err),
                "path:",
                path
            )
        }
    }
}