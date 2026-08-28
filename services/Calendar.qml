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

    function recurrenceIndex(event, date) {
        if (!event.recurrence)
            return -1

        const start = parseDate(event.date)

        const frequency =
            event.recurrence.frequency

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

    function todosForDate(date) {
        const key = dateKey(date)

        return root.todos.filter(todo =>
            todo.dueDate === key
        )
    }

    function hasItemsForDate(date) {
        const key = dateKey(date)

        return root.events.some(event =>
            eventOccursOnDate(
                event,
                date
            )
        ) || root.todos.some(todo =>
            todo.dueDate === key
        )
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

    function addTodo(title, dueDate) {
        const todo = {
            id: makeId("todo"),
            title: title,
            dueDate: dueDate
                ? dateKey(dueDate)
                : "",
            completed: false
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

    function toggleTodo(id) {
        root.todos = root.todos.map(todo => {
            if (todo.id !== id)
                return todo

            return Object.assign(
                {},
                todo,
                {
                    completed:
                        !todo.completed
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
                        events: root.events,
                        todos: root.todos
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
                    Array.isArray(data.events)
                    ? data.events
                    : []

                root.todos =
                    Array.isArray(data.todos)
                    ? data.todos
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