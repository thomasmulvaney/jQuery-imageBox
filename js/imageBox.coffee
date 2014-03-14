(($, window) ->
  $.fn.extend 'imageBox': (option, args) ->
    funk = ($e) -> 
      data = $e.data('imageBox')
      if !data
        $e.data 'imageBox', (data = new ImageBox($e, option))
      if typeof option is 'string'
        args = [].concat(args)
        data[option].apply(data, args)

    if @length is 1
      funk $(this)
    else
      @each ->
        funk $(this)

  class ImageBox
    _events: ->
      self = this

      @$image.on 'mousewheel', (e) ->
        pos = Math.round(e.originalEvent.wheelDelta)
        if pos > 0
          scaling = pos / 100
        else
          scaling = pos / -200

        wh = $(this).css('background-size').split(' ')
        w = Number(wh[0].replace('px','')) * scaling
        h = Number(wh[1].replace('px','')) * scaling

        $(this).css('background-size', "#{w}px #{h}px")


      @$image.on 'dblclick', (e) ->
        self.$image.css('background-position', '0px 0px')
        self.resize(self.stockHeight, self.stockWidth)

      @$image.on 'mousedown', (e) ->
        curX = e.pageX
        curY = e.pageY
        xy = self.$image.css('background-position').split(' ')
        curX = curX - Number(xy[0].replace('px',''))
        curY = curY - Number(xy[1].replace('px',''))

        handler = (e) ->
          unless e.type is 'mouseup'
            x = Math.ceil(e.pageX - curX) 
            y = Math.ceil(e.pageY - curY)
            $(this).css('background-position', "#{x}px #{y}px")
          else
            destroy()

        destroy = ->
          self.$image.off('mouseup mousemove', handler)

        self.$image.on 'mouseup mousemove', handler
        self.$image.on 'mouseleave', destroy
      
    constructor: (@element, options) ->
      # Setup options 
      @stretchToCanvas = options.stretchToCanvas or true 
      @stockHeight = @element.height()
      @stockWidth  = @element.width()

      # Initialize image to dom
      @image = document.createElement('div') 
      @$image = $(@image)
      @element.append(@image)
      @clearImage()

      # Init events
      @_events()

    # Sets image src
    setImage: (img) ->
      self = this
      @$image.css('cursor', 'move')
      _image = new Image()
      _image.addEventListener 'load', ->
        self.$image.css('background-image', "url('#{img}')")
        self.resize(this.height, this.width)
        self.stockHeight = this.height
        self.stockWidth = this.width
        _image = null

      _image.src = img

    # Resize the image
    resize: (height, width) ->
      eWidth = @element.width()
      eHeight = @element.height()

      if width <= eWidth and @stretchToCanvas
        w = eWidth
      else
        w = width

      if height <= eHeight and @stretchToCanvas
        h = eHeight
      else
        h = height

      @$image.css('background-size', "#{w}px  #{h}px")

    # This gets the X1, Y1, X2, Y2 co-ords
    # This is garbage right now :(
    getXY: ->
      xy = @$image.css('background-position').split(' ')
      imageX = Number(xy[0].replace('px',''))
      imageY = Number(xy[1].replace('px',''))

      wh = @$image.css('background-size').split(' ')
      w = Number(wh[0].replace('px',''))
      h = Number(wh[1].replace('px',''))

      elemH = @element.height()
      elemW = @element.width()

      coords =
        "W":  w 
        "H":  h
        "X1": (-1 * imageX)
        "X2": (elemW + imageX)
        "Y1": (-1 * imageX) 
        "Y2": (elemH + imageY) 
      return coords

    # Clears the current image from the canvas
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

)(window.jQuery, window)
