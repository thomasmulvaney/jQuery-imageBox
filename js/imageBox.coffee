#
# imageBox, a plugin for jQuery
# Instructions: https://github.com/wavejumper/jQuery-imageBox 
# By: Thomas Crowley
# Updated: March 14, 2014
#

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

    _events: ->
      self = this

      # Resize image on mousewheel
      # The scaling sucks right now
      @$image.on 'mousewheel', (e) ->
        pos = Math.round(e.originalEvent.wheelDelta)
        if pos > 0
          scaling = pos / 100
        else
          scaling = pos / -200

        w = self._backgroundSize()[0] * scaling
        h = self._backgroundSize()[1] * scaling
        self.resize(h, w)

      # Reset image position/size on double click
      @$image.on 'dblclick', (e) ->
        self.$image.css('background-position', '0px 0px')
        self.resize(self.stockHeight, self.stockWidth)

      # Move the image on mousedown drag
      @$image.on 'mousedown', (e) ->
        curX = e.pageX - self._backgroundPosition()[0] 
        curY = e.pageY - self._backgroundPosition()[1] 

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
        self.resize(this.height, this.width)
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

)(window.jQuery, window)
