'use strict'

<datepicker>
  <input class="datepicker"
         id={ id }
         onchange={ set_date }
         type="date"
         value={ opts.value } />

  <script>
    this.id = 'datepicker-' + Math.random().toString(36).slice(-8)

    this.on('mount', function() {
        $('#' + this.id).pickadate({
            format:           'yyyy/mm/dd',
            labelMonthNext:   '翌月',
            labelMonthPrev:   '前月',
            labelMonthSelect: '月を選択',
            labelYearSelect:  '年 (西暦) を選択',
            monthsFull: [
                '1 月', '2 月', '3 月',  '4 月',  '5 月',  '6 月',
                '7 月', '8 月', '9 月', '10 月', '11 月', '12 月'
            ],
            monthsShort: [
                '1 月', '2 月', '3 月',  '4 月',  '5 月',  '6 月',
                '7 月', '8 月', '9 月', '10 月', '11 月', '12 月'
            ],
            weekdaysFull: [
                '日曜日', '月曜日', '火曜日', '水曜日',
                '木曜日', '金曜日', '土曜日'
            ],
            weekdaysShort: [
                '日曜', '月曜', '火曜', '水曜', '木曜', '金曜', '土曜'
            ],
            weekdaysLetter: [ '日', '月', '火', '水', '木', '金', '土' ],
            today: '今日',
            clear: 'クリア',
            close: '閉じる',
        })
    })

    set_date() { this.opts.setter(this[this.id].value) }
  </script>
</datepicker>
