POLLING_TIME = 1000

pageAction 'upload_jobs', 'show', ->
  $container = $('.upload-job-js')
  return unless $container.length

  data = $container.data()

  poller = new UploadJobPoller($container, data.id, data)
  poller.startPolling()


class UploadJobPoller
  constructor: (@$container, @id, data) ->
    @createStatusContainer()
    @updateStatus(data)
    @currentStage = null


  # Poll continuously until the job is done
  startPolling: -> @poll(true)


  poll: (repeat) ->
    $.getJSON(@job_url())
      .done (data) =>
        @updateStatus(data)
        setTimeout((=> @poll(true)), POLLING_TIME) if repeat && !@finished
      .fail ->
        # Our TheKey.me auth probably expired
        window.location.reload(true)


  job_url: -> "/upload_jobs/#{@id}/status"


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
    $note = $('<p class="upload-job__note">').text(
      'You can now leave this page. The import will continue.'
    )

    @$statusContainer = $('<div class="upload-job__status">')
    @$jobMessage = $('<div class="upload-job__message">')

    @$container.empty().append(
      $('<div class="upload-job">').append(@$statusContainer, @$jobMessage,
                                           $note)
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
