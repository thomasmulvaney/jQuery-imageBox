#
# imageBox, a plugin for jQuery
# Instructions: https://github.com/wavejumper/jQuery-imageBox
# By: Thomas Crowley, Thomas Mulvaney
# Updated: March 15, 2014
#

((window) ->
  $.fn.extend 'imageBox': (option, args) ->
    funk = ($e) ->
      data = $e.data('imageBox')
      if !data
        $e.data 'imageBox', (data = new ImageBox($e, option))
      if typeof option is 'string'
        args = [].concat(args)
        data[option].apply(data, args)

    if @length is 1
      # so we can return the result of the function
      # if there is just one element
      funk $(this)
    else
      @each ->
        funk $(this)

  class ImageBox
    #
    # Private methods
    #
    _backgroundSize: ->
      bs = @$image.css('background-size').split(' ')
      (Number(e.replace('px','')) for e in bs)

    _backgroundPosition: ->
      bp = @$image.css('background-position').split(' ')
      (Number(e.replace('px','')) for e in bp)

    _withinBoundsN: (imageN, elemN, pos) ->
      maxMove = elemN - imageN
      if pos >= 0
        n = 0
      else if pos <= maxMove
        n = maxMove
      else
        n = pos

    _withinBoundsX: (x) ->
      imgWidth  = @_backgroundSize()[0]
      eWidth = @element.width()
      @_withinBoundsN imgWidth, eWidth, x

    _withinBoundsY: (y) ->
      imgHeight  = @_backgroundSize()[1]
      eHeight = @element.height()
      @_withinBoundsN imgHeight, eHeight, y

    _events: ->
      self = this

      # Resize image on mousewheel
      @$image.on 'mousewheel', (e) ->
        pos = Math.round(e.originalEvent.wheelDelta)
        if pos > 0
          scaling = pos / 100
        else
          scaling = pos / -200

        curX = e.originalEvent.pageX - self._backgroundPosition()[0]
        curY = e.originalEvent.pageY - self._backgroundPosition()[1]

        # Resize
        w = self._backgroundSize()[0] * scaling
        h = self._backgroundSize()[1] * scaling
        self.resize(h, w)

        # Pan
        x = curX - self._backgroundPosition()[0]
        y = curY - self._backgroundPosition()[1]
        self.move(x, y)

      # Reset image position/size on double click
      @$image.on 'dblclick', (e) ->
        self.$image.css('background-position', '0px 0px')
        self.zoomFit()

      # Move the image on mousedown drag
      @$image.on 'mousedown', (e) ->
        curX = e.pageX - self._backgroundPosition()[0]
        curY = e.pageY - self._backgroundPosition()[1]
        handler = (e) ->
          unless e.type is 'mouseup'
            self.move (e.pageX - curX), (e.pageY - curY)
          else
            destroy()

        destroy = ->
          self.$image.off('mouseup mousemove', handler)

        self.$image.on 'mouseup mousemove', handler
        self.$image.on 'mouseleave', destroy

    constructor: (@element, options) ->
      options = options or {}
      # Setup options
      @stretchToCanvas = options.stretchToCanvas or true
      @superZoom       = options.superZoom or false
      @stockHeight = @element.height()
      @stockWidth  = @element.width()
      # Initialize image to dom
      @image = document.createElement('div')
      @$image = $(@image)
      @element.append(@image)
      @clearImage()

      # Init events
      @_events()

    #
    # Public methods
    #
    # Sets image 'src' attribute
    setImage: (img) ->
      self = this

      _image = new Image()
      _image.addEventListener 'load', ->
        self.$image.css('background-image', "url('#{img}')")
        self.$image.css('cursor', 'move')
        self.stockHeight = this.height
        self.stockWidth = this.width
        self.stockRatio =
          Math.min (this.width/self.element.width()),
                   (this.height/self.element.height())
        self.zoomFit()
        _image = null
      _image.src = img

    zoomFit: () ->
      if @stretchToCanvas
        scaleFactor = 1.0 / @stockRatio

        w = @stockWidth * scaleFactor
        h = @stockHeight * scaleFactor

        @$image.css('background-size', "#{w}px  #{h}px")

    # Resize the image
    resize: (height, width) ->
      unless @stretchToCanvas
        @$image.css('background-size', "#{width}px  #{height}px")
      else
        # Given the dimensions of the canvas, if the image is
        # smaller than either or both dimensions we need to scale
        # it so it fits both.
        eWidth = @element.width()
        eHeight = @element.height()
        wRatio = width/eWidth
        hRatio = height/eHeight
        minRatio = Math.min wRatio, hRatio

        if minRatio < 1.0
          scaleFactor = 1.0 / minRatio
        else
          scaleFactor = 1.0

        w = width * scaleFactor
        h = height * scaleFactor

        unless @superZoom
          # If one or more dimensions is smaller than the element we have no
          # choice but to upscale the minimum dimension.
          if @stockRatio < 1.0
            @zoomFit()
          else
            w = Math.min @stockWidth,  w
            h = Math.min @stockHeight, h
            @$image.css('background-size', "#{w}px  #{h}px")

    # Move the image in the element, aka panning
    move: (dx, dy) ->
      x = Math.ceil @_withinBoundsX dx
      y = Math.ceil @_withinBoundsY dy
      @$image.css('background-position', "#{x}px #{y}px")

    # Gets the X1, Y1, X2, Y2 co-ords
    # This is garbage right now :(
    getXY: ->
      imageX = @_backgroundPosition()[0]
      imageY = @_backgroundPosition()[1]
      elemH = @element.height()
      elemW = @element.width()

      coords =
        "W":  @_backgroundSize()[0]
        "H":  @_backgroundSize()[1]
        "X1": (-1 * imageX)
        "X2": (elemW + imageX)
        "Y1": (-1 * imageX)
        "Y2": (elemH + imageY)

    # Clears the current image from canvas
    clearImage: ->
      @$image.css('background-position', "0px 0px")
      @$image.css('background-image', 'none')
      @$image.css('-webkit-user-select', 'none')
      @$image.css('-webkit-user-drag', 'none')
      @$image.css('cursor', 'auto')
      @$image.css('background-size', "0px 0px")
      @$image.css('height', @element.height())
      @$image.css('width', @element.width())
      @$image.css('background-repeat', 'no-repeat no-repeat')
      @$image.css('border', 'none')

)(window)
