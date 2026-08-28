pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
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

    function makeId(prefix) {
        return `${prefix}-${Date.now()}-${Math.floor(Math.random() * 100000)}`
    }

    function save() {
        if (!root.loaded)
            return

        saveTimer.restart()
    }

    function eventsForDate(date) {
        const key = dateKey(date)

        return root.events
            .filter(event => event.date === key)
            .slice()
            .sort((a, b) => {
                const timeA = a.time || ""
                const timeB = b.time || ""

                return timeA.localeCompare(timeB)
            })
    }

    function todosForDate(date) {
        const key = dateKey(date)

        return root.todos.filter(todo => todo.dueDate === key)
    }

    function hasItemsForDate(date) {
        const key = dateKey(date)

        return root.events.some(event => event.date === key)
            || root.todos.some(todo => todo.dueDate === key)
    }

    function addEvent(title, date, time, notes) {
        const event = {
            id: makeId("event"),
            title: title,
            date: dateKey(date),
            time: time || "",
            notes: notes || ""
        }

        root.events = [...root.events, event]
        save()

        return event.id
    }

    function updateEvent(id, changes) {
        root.events = root.events.map(event => {
            if (event.id !== id)
                return event

            return Object.assign({}, event, changes)
        })

        save()
    }

    function removeEvent(id) {
        root.events = root.events.filter(event => event.id !== id)
        save()
    }

    function addTodo(title, dueDate) {
        const todo = {
            id: makeId("todo"),
            title: title,
            dueDate: dueDate ? dateKey(dueDate) : "",
            completed: false
        }

        root.todos = [...root.todos, todo]
        save()

        return todo.id
    }

    function updateTodo(id, changes) {
        root.todos = root.todos.map(todo => {
            if (todo.id !== id)
                return todo

            return Object.assign({}, todo, changes)
        })

        save()
    }

    function toggleTodo(id) {
        root.todos = root.todos.map(todo => {
            if (todo.id !== id)
                return todo

            return Object.assign({}, todo, {
                completed: !todo.completed
            })
        })

        save()
    }

    function removeTodo(id) {
        root.todos = root.todos.filter(todo => todo.id !== id)
        save()
    }

    Timer {
        id: saveTimer

        interval: 1000

        onTriggered: {
            storage.setText(JSON.stringify({
                events: root.events,
                todos: root.todos
            }, null, 2))
        }
    }

    FileView {
        id: storage

        path: `${Paths.state}/calendar.json`

        onLoaded: {
            try {
                const data = JSON.parse(text())

                root.events = Array.isArray(data.events)
                    ? data.events
                    : []

                root.todos = Array.isArray(data.todos)
                    ? data.todos
                    : []
            } catch (e) {
                root.events = []
                root.todos = []
            }

            root.loaded = true
        }

        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.events = []
                root.todos = []
                root.loaded = true

                setText(JSON.stringify({
                    events: [],
                    todos: []
                }, null, 2))
            }
        }
    }
}
