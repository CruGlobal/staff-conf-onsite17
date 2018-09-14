POLLING_TIME = 1000

# $ ->
#   $('form.upload-job-js').each ->
#     $form = $(this)

#     $form.on 'submit', replaceSubmitButtons
#     ajaxForm($form)


# Replace the form's submit buttons, to avoid a double-submit.
replaceSubmitButtons = ->
  $(this).find('fieldset.actions > ol').replaceWith(
    $('<ol>').append(
      $('<li class="cancel">').append(
        $('<a>').attr('href', window.location.href).text('New Upload Form')
      )
    )
  )


# Use jQuery.form plugin to submit form via AJAX.
ajaxForm = ($form) ->
  options =
    dataType: 'json'
    success: startPolling

  $form.ajaxForm options


# Start polling the server for updates
startPolling = (data, textStatus, jqXHR, $form) ->
  poller = new UploadJobPoller($form, data.id, data)
  poller.startPolling()


class UploadJobPoller
  constructor: (@$form, @id, data) ->
    @createStatusContainer()
    @updateStatus(data)
    @currentStage = null


  # Poll continuously until the job is done
  startPolling: -> @poll(true)


  poll: (repeat) ->
    $.getJSON(@job_url()).done (data) =>
      @updateStatus(data)
      setTimeout((=> @poll(true)), POLLING_TIME) if repeat && !@finished


  job_url: -> "/upload_job/#{@id}"


  updateStatus: (data) ->
    stageChanged = @stage != data.stage
    @createNewCurrentStage(data.stage) if stageChanged
    @stage = data.stage

    @finished = data.finished
    @success = data.success
    @percentage = data.percentage

    @message = data.html_message
    @message = 'Finished Import!' if @finished && !@message

    @updateStatusMessage()
    @currentStage.update(@finished, @success, @percentage) if @currentStage


  updateStatusMessage: ->
    @$jobMessage.html(@message)
    @setJobMessageStyle()


  createNewCurrentStage: (stage)->
    return if stage == 'queued'

    @currentStage.finish(!@finished || @success) if @currentStage
    @currentStage = new StageStatus(stage)
    @$statusContainer.append(@currentStage.$elem)


  createStatusContainer: ->
    $title = $('<h3>').text('Upload Progress')
    $note = $('<p class="upload-job__note">').text(
      'You can now leave this page. The import will continue.'
    )

    @$statusContainer = $('<div class="upload-job__status">')
    @$jobMessage = $('<div class="upload-job__message">')

    @$form.after(
      $('<div class="upload-job">').append($title, $note, @$statusContainer,
                                           @$jobMessage)
    )


  setJobMessageStyle: ->
    @$jobMessage.removeClass('flash_notice flash_error')

    return unless @message?.length

    if @success
      @$jobMessage.addClass('flash flash_notice')
    else
      @$jobMessage.addClass('flash flash_error')


class StageStatus
  constructor: (@stage) ->
    @$elem = @createStatusMessage()
    @update(false, false, 0)


  createStatusMessage: ->
    @$jobStatus = $('<div class="upload-job__status">').text(@stage)

    $progressContainer = $('<div class="upload-job__progress">')
    @$jobProgress = $('<div class="upload-job__progress-bar">').
                      appendTo($progressContainer)

    $('<div class="upload-job">').append(@$jobStatus, $progressContainer,
                                         @$jobMessage)


  finish: (success) -> @update(true, success, 1)


  update: (finished, success, percentage) ->
    @finished = finished
    @success = success
    @percentage = percentage

    @updateJobProcessStyle()


  updateJobProcessStyle: ->
    if @finished
      @$jobProgress.css(width: '100%')

      if @success
        @$jobProgress.addClass('upload-job__progress-bar--success')
      else
        @$jobProgress.addClass('upload-job__progress-bar--error')
    else
      @$jobProgress.css(width: "#{@percentage * 100.0}%")
