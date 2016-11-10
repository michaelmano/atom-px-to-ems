PxToEmView = require './px-to-em-view'
{CompositeDisposable} = require 'atom'

module.exports = PxToEm =
   config:
      Unit:
        type: 'string'
        description: 'Choose a type of output unit.'
        default: 'em'
        enum: [
          'em'
          'rem'
        ],
      Base:
        type: 'string'
        description: 'Choose a default base.'
        default: '16'

   pxToEmView: null
   modalPanel: null
   subscriptions: null

   activate: ->
      atom.commands.add 'atom-workspace', 'px-to-em:toggle': => @convert()

   convert: ->
      unit = 'em'
      atom.config.observe 'px-to-em.Unit', (type) ->
        if type == 'rem'
          unit = 'rem'

      editor = atom.workspace.getActivePaneItem()
      #select current line
      selection = editor.selectLinesContainingCursors()
      #get line value
      original = editor.getLastSelection()
      #save line value
      text = original.getText().replace(' /', '/')
      #get init of the base
      initBase = text.search('/')
      #save the base value
      base = text.slice(initBase).slice(1)
      #get init of the px value
      values = text.match(/([0-9]+)px/gi)
      #if values exist
      if values != null
         #if not specify a base value is generated default
         if base == ''
            base = '16'
            atom.config.observe 'px-to-em.Base', (newBase) ->
              base = newBase
            text = text + ' '
         #each the px values
         values.forEach (val, key) ->
            text = text.replace(val, parseInt(val)/base + unit)
            if key < values.length-1
               text = text.concat('/* ' + parseInt(val) + ' */ ').replace(/(\r\n|\n|\r)/gi, '')
            else
               fullBase = '/'+base.replace(/(\r\n|\n|\r)/gi, '')
               text = text.replace(fullBase, ' ').replace(/(\r\n|\n|\r)/gi, '') + ('/* ' + parseInt(val) + ' */')
               text = text.replace(/\ \*\//g, '/' + base.replace(/(\r\n|\n|\r)/gi, '') + ' */')
               text = text + '\n'

      original.insertText(text)
