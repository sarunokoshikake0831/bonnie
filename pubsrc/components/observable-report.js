'use strict'

const riot      = require('riot')
const moment    = require('moment')
const constants = require('./constants.json')


/*
 * レポートの状態保持に Riot の Observalbe を利用してみた。
 * set_state() とか reset() で状態を更新すると、update_event が飛ぶ。
 * シンプルだけどかなり使える。
 */
const report_attributes = [
    'report_type',
    'title',

    'occurrence_date',
    'occurrence_time',
    'occurrence_floor',
    'occurrence_room',

    'report_date',
    'reporter_type',

    'event0',
    'event1',

    'detail',
    'cause',
    'consideration',
    'countermeasure'
]

module.exports = class {
    constructor(update_event, report) {
        riot.observable(this)

        this.update_event = update_event
    
        if (report) {
            report_attributes.forEach(a => this[a] = report[a])
        } else {
            this.reset()
        }
    }

    reset() {
        this.report_type = 'incident'
        this.title       = ''

        this.occurrence_date  = moment().format('YYYY/MM/DD')
        this.occurrence_time  = `${constants.hours[0]}:${constants.mins[0]}`
        this.occurrence_floor = constants.floors[0].toString()
        this.occurrence_room  = constants.rooms[0]
    
        this.report_date   = moment().format('YYYY/MM/DD')
        this.reporter_type = constants.reporter_types[0]
    
        this.event0 = '0'
        this.event1 = '0'
    
        this.detail         = ''
        this.cause          = ''
        this.consideration  = ''
        this.countermeasure = ''
    }

    set_state(name) {
        return value => {
            this[name] = value
            this.trigger(this.update_event)
        }
    }

    make_report() {
        let report = {}

        report_attributes.forEach( (a) => report[a] = this[a] )

        return report
    }
}
