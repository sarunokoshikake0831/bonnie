'use strict'

require('riot')

require('./datepicker.tag')
require('./custom-textarea.tag')

const constants = require('./constants.json')

<overview>
  <style scoped>
    :scope {
      display: block;
      margin:  16px 0 32px 0;
    }

    .div__type        { margin:       16px 0 16px 0}
    .div__tpo         { display:      flex }
    .any__right-space { margin-right: 16px }
    .any__top-space   { margin-top:   11px }
    .any__short       { width:  36px }
    .any__medium      { width:  64px }
    .any__long        { width:  96px }
    .any__long-long   { width: 128px }
  </style>

  <h4>概要</h4>
  <div class="div__type">
    <input checked={ opts.props.report_type == 'incident'? 'checked': null }
           id={ 'type-incident-' + id_sfx }
           onchange={ set_report_type }
           name={ "report-type" + id_sfx }
           type="radio"
           value="incident" />
    <label for={ 'type-incident-' + id_sfx }>インシデント</label>
    <input checked={ opts.props.report_type == 'trouble'? 'checked': null }
           id={ 'type-trouble-' + id_sfx }
           onchange={ set_report_type }
           name={ "report-type" + id_sfx }
           type="radio"
           value="trouble" />
    <label for={ 'type-trouble-' + id_sfx }>苦情・トラブル</span>
  </div>

  <div class="row">
    <div class="input-field col s12">
      <input id={ 'title-' + id_sfx }
             maxlength="48"
             onchange={ set_state('title') }
             type="text"
             value={ opts.props.title } />
      <label for={ 'title-' + id_sfx }>表題</label>
    </div>
  </div>

  <div class="row">
    <div class="col s12">
      <div class="card-panel">
        <div class="div__tpo">
          <div class="any__long any__right-space">
            <datepicker setter={ opts.props.set_state('occurrence_date') }
                        value={ opts.props.occurrence_date } />
          </div>
          <select class="any__short any__right-space"
                  id={ 'occurrence_hour-' + id_sfx }
                  onchange={ set_occurrence_time }>
            <option each={ hour in constants.hours }
                    selected={ parent.is_selected('occurrence_hour', hour) }
                    value={ hour }>
              { hour }
            </option>
          </select>
          <span class="any__top-space any__right-space">時</span>
          <select class="any__short any__right-space"
                  id={ 'occurrence_min-' + id_sfx }
                  onchange={ set_occurrence_time }>
            <option each={ min in constants.mins }
                    selected={ parent.is_selected('occurrence_min', min) }
                    value={ min }>
              { min }
            </option>
          </select>
          <span class="any__top-space any__right-space">分頃</span>
          <select class="any__short any__right-space"
                  id={ 'occurrence_floor-' + id_sfx }
                  onchange={ set_state('occurrence_floor') }>
            <option each={ floor in constants.floors }
                    selected={ parent.is_selected('occurrence_floor', floor) }
                    value={ floor }>
              { floor }
            </option>
          </select>
          <span class="any__top-space any__right-space">階</span>
          <select class="any__medium any__right-space"
                  id={ 'occurrence_room-' + id_sfx }
                  onchange={ set_state('occurrence_room') }>
            <option each={ room in constants.rooms }
                    selected={ parent.is_selected('occurrence_room', room) }
                    value={ room }>
              { room }
            </option>
          </select>
          <span class="any__top-space">で発生</span>
        </div>

        <div class="div__tpo">
          <div class="any__long any__right-space">
            <datepicker setter={ opts.props.set_state('report_date') }
                        value={ opts.props.report_date } />
          </div>
          <select class="any__long-long any__right-space"
                  id={ 'reporter_type-' + id_sfx }
                  onchange={ set_state('reporter_type') }>
            <option each={ type in constants.reporter_types }
                    selected={ parent.is_selected('reporter_type', type) }
                    value={ type }>
              { type }
            </option>
          </select>
          <span class="any__top-space">が報告</span>
        </div>
      </div>
    </div>
  </div>

  <script>
    this.constants = constants
    this.id_sfx    = Math.random().toString(36).slice(-8)

    this.on('mount', function() { $('select').material_select() })

    set_report_type(e)  {
        this.opts.props.set_state('report_type')(e.target.value)
    }

    set_state(attr) {
        const id = `${attr}-${this.id_sfx}`

        return () => this.opts.props.set_state(attr)(this[id].value)
    }

    set_occurrence_time() {
        const hour = this[`occurrence_hour-${this.id_sfx}`].value
        const min  = this[`occurrence_min-${this.id_sfx}`].value
        this.opts.props.set_state('occurrence_time')(`${hour}:${min}`)
    }

    is_selected(target, item) {
        let target_value

        switch (target) {
        case 'occurrence_hour':
        case 'occurrence_min':
            const time  = this.opts.props.occurrence_time
            const match = time.match(/^(\d\d):(\d\d)$/)
            const hour  = match[1]
            const min   = match[2]

            target_value = target == 'occurrence_hour'? hour: min
            break
        default:
            target_value = this.opts.props[target]
        }

        return target_value == item? 'selected': null
    }
  </script>
</overview>

<event-select>
  <style scoped>
    ul { list-style-type: none }
  </style>

  <div class="row">
    <div class="col s12">
      <div class="card-panel">
        <ul>
          <li each={ e, i in opts.events }>
            <input checked={ parent.is_checked(e.id) }
                   id={ parent.get_id(i) }
                   name={ parent.group_name }
                   onchange={ parent.set_state }
                   type="radio"
                   value={ e.id } />
            <label for={ parent.get_id(i) }>
              { e.desc }
            </label>
          </li>
        </ul>
      </div>
    </div>
  </div>

  <script>
    const id_sfx    = Math.random().toString(36).slice(-8)
    this.group_name = this.opts.event + '-' + id_sfx

    set_state(e) {
        this.opts.props.set_state(this.opts.event)(e.target.value)
    }

    is_checked(id) {
        return this.opts.props[this.opts.event] == id? "checked": null
    }

    get_id(i) {
        return this.opts.event + '-' + i.toString() + '-' + id_sfx
    }
  </script>
</event-select>

<event-select-0>
  <h4>事象内容 1</h4>
  <event-select event="event0" events={ events } props={ opts.props } />

  <script>
    this.events = constants.event0
  </script>
</event-select-0>

<event-select-1>
  <h4>事象内容 2</h4>
  <event-select event="event1" events={ events } props={ opts.props } />

  <script>
    this.events = constants.event1
  </script>
</event-select-1>

<report-common>
  <overview props={ opts.props } />
  <event-select-0 if={ opts.props.report_type == 'incident' }
                  props={ opts.props } />
  <event-select-1 if={ opts.props.report_type == 'incident' }
                  props={ opts.props } />
  <custom-textarea id="detail"
                   label="事象詳細"
                   maxlength=512
                   props={ opts.props } />
  <custom-textarea id="cause"
                   label="原因及び要因"
                   maxlength=256
                   props={ opts.props } />
  <custom-textarea id="consideration"
                   label="検討事項"
                   maxlength=256
                   props={ opts.props } />
  <custom-textarea id="countermeasure"
                   label="対策"
                   maxlength=256
                   props={ opts.props } />
</report-common>
