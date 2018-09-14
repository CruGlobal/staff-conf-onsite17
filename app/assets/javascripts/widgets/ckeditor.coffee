setupCkeditor = ->
  $(this).ckeditor(
    allowedContent: true

    # Toolbar groups configuration.
    toolbar: [
      {
        name:   'clipboard',
        groups: ['clipboard', 'undo'],
        items:  ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-',
                 'Undo', 'Redo']
      },
      {
        name:  'links',
        items: ['Link', 'Unlink', 'Anchor']
      },
      {
        name:  'insert',
        items: ['Table', 'HorizontalRule', 'SpecialChar']
      },
      {
        name:   'paragraph',
        groups: ['list', 'indent', 'blocks', 'align', 'bidi'],
        items:  ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-',
                 'Blockquote', '-', 'JustifyLeft', 'JustifyCenter',
                 'JustifyRight', 'JustifyBlock']
      },
      '/',
      {
        name:   'styles',
        items: ['Styles', 'Format', 'Font', 'FontSize']
      },
      {
        name:  'colors',
        items: ['TextColor', 'BGColor']
      },
      {
        name:   'basicstyles',
        groups: ['basicstyles', 'cleanup'],
        items:  ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript',
                 'Superscript', '-', 'RemoveFormat', 'Source']
      }
    ]

    toolbar_mini: [
      {
        name:   'paragraph',
        groups: ['list', 'indent', 'blocks', 'align', 'bidi'],
        items:  ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-',
                 'Blockquote', '-', 'JustifyLeft', 'JustifyCenter',
                 'JustifyRight', 'JustifyBlock']
      },
      {
        name:  'styles',
        items: ['Font', 'FontSize'] },
      {
        name:  'colors',
        items: ['TextColor', 'BGColor'] },
      {
        name:   'basicstyles',
        groups: ['basicstyles', 'cleanup'],
        items:  ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript',
                 'Superscript', '-']
      },
      {
        name:  'insert',
        items: ['Image', 'Table', 'HorizontalRule', 'SpecialChar'] }
    ]
  )

$ ->
  $('body').on 'DOMNodeInserted', (event) ->
    $('.ckeditor_input', event.target).each(setupCkeditor)

  $('.ckeditor_input').each(setupCkeditor)
