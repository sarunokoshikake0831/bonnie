'use strict'

<custom-textarea>
  <style scoped>
    textarea { width: calc(100% - 24px) }
  </style>

  <div class="row">
    <div class="input-field col s12">
      <textarea class="materialize-textarea"
                id={ id }
                onchange={ set_state }
                maxlength={ opts.maxlength }
                rows={ opts.rows }>{ opts.props[opts.id] }</textarea>
      <label for={ id }>{ opts.label }</label>
  </div>

  <script>
    this.id = 'textarea-' + Math.random().toString(36).slice(-8)

    set_state() {
        this.opts.props.set_state(this.opts.id)(this[this.id].value)
    }
  </script>
</custom-textarea>
