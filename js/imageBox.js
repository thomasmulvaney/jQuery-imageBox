// Generated by CoffeeScript 1.7.1
(function() {
  (function(window) {
    var ImageBox;
    $.fn.extend({
      'imageBox': function(option, args) {
        var funk;
        funk = function($e) {
          var data;
          data = $e.data('imageBox');
          if (!data) {
            $e.data('imageBox', (data = new ImageBox($e, option)));
          }
          if (typeof option === 'string') {
            args = [].concat(args);
            return data[option].apply(data, args);
          }
        };
        if (this.length === 1) {
          return funk($(this));
        } else {
          return this.each(function() {
            return funk($(this));
          });
        }
      }
    });
    return ImageBox = (function() {
      ImageBox.prototype._backgroundSize = function() {
        var bs, e, _i, _len, _results;
        bs = this.$image.css('background-size').split(' ');
        _results = [];
        for (_i = 0, _len = bs.length; _i < _len; _i++) {
          e = bs[_i];
          _results.push(Number(e.replace('px', '')));
        }
        return _results;
      };

      ImageBox.prototype._backgroundPosition = function() {
        var bp, e, _i, _len, _results;
        bp = this.$image.css('background-position').split(' ');
        _results = [];
        for (_i = 0, _len = bp.length; _i < _len; _i++) {
          e = bp[_i];
          _results.push(Number(e.replace('px', '')));
        }
        return _results;
      };

      ImageBox.prototype._withinBoundsN = function(imageN, elemN, pos) {
        var maxMove, n;
        maxMove = elemN - imageN;
        if (pos >= 0) {
          return n = 0;
        } else if (pos <= maxMove) {
          return n = maxMove;
        } else {
          return n = pos;
        }
      };

      ImageBox.prototype._withinBoundsX = function(x) {
        var eWidth, imgWidth, n;
        imgWidth = this._backgroundSize()[0];
        eWidth = this.element.width();
        return n = this._withinBoundsN(imgWidth, eWidth, x);
      };

      ImageBox.prototype._withinBoundsY = function(y) {
        var eHeight, imgHeight, n;
        imgHeight = this._backgroundSize()[1];
        eHeight = this.element.height();
        return n = this._withinBoundsN(imgHeight, eHeight, y);
      };

      ImageBox.prototype._move = function(dx, dy) {
        var x, y;
        x = Math.ceil(this._withinBoundsX(dx));
        y = Math.ceil(this._withinBoundsY(dy));
        return this.$image.css('background-position', "" + x + "px " + y + "px");
      };

      ImageBox.prototype._events = function() {
        var self;
        self = this;
        this.$image.on('mousewheel', function(e) {
          var curX, curY, h, pos, scaling, w, x, y;
          pos = Math.round(e.originalEvent.wheelDelta);
          if (pos > 0) {
            scaling = pos / 100;
          } else {
            scaling = pos / -200;
          }
          curX = e.originalEvent.pageX - self._backgroundPosition()[0];
          curY = e.originalEvent.pageY - self._backgroundPosition()[1];
          w = self._backgroundSize()[0] * scaling;
          h = self._backgroundSize()[1] * scaling;
          self.resize(h, w);
          x = curX - self._backgroundPosition()[0];
          y = curY - self._backgroundPosition()[1];
          return self._move(x, y);
        });
        this.$image.on('dblclick', function(e) {
          self.$image.css('background-position', '0px 0px');
          return self.zoomFit();
        });
        return this.$image.on('mousedown', function(e) {
          var curX, curY, destroy, handler;
          curX = e.pageX - self._backgroundPosition()[0];
          curY = e.pageY - self._backgroundPosition()[1];
          handler = function(e) {
            if (e.type !== 'mouseup') {
              return self._move(e.pageX - curX, e.pageY - curY);
            } else {
              return destroy();
            }
          };
          destroy = function() {
            return self.$image.off('mouseup mousemove', handler);
          };
          self.$image.on('mouseup mousemove', handler);
          return self.$image.on('mouseleave', destroy);
        });
      };

      function ImageBox(element, options) {
        this.element = element;
        options = options || {};
        this.stretchToCanvas = options.stretchToCanvas || true;
        this.superZoom = options.superZoom || false;
        this.stockHeight = this.element.height();
        this.stockWidth = this.element.width();
        this.image = document.createElement('div');
        this.$image = $(this.image);
        this.element.append(this.image);
        this.clearImage();
        this._events();
      }

      ImageBox.prototype.setImage = function(img) {
        var self, _image;
        self = this;
        _image = new Image();
        _image.addEventListener('load', function() {
          self.$image.css('background-image', "url('" + img + "')");
          self.$image.css('cursor', 'move');
          self.stockHeight = this.height;
          self.stockWidth = this.width;
          self.stockRatio = Math.min(this.width / self.element.width(), this.height / self.element.height());
          self.zoomFit();
          return _image = null;
        });
        return _image.src = img;
      };

      ImageBox.prototype.zoomFit = function() {
        var h, scaleFactor, w;
        if (this.stretchToCanvas) {
          scaleFactor = 1.0 / this.stockRatio;
          w = this.stockWidth * scaleFactor;
          h = this.stockHeight * scaleFactor;
          return this.$image.css('background-size', "" + w + "px  " + h + "px");
        }
      };

      ImageBox.prototype.resize = function(height, width) {
        var eHeight, eWidth, h, hRatio, minRatio, scaleFactor, w, wRatio;
        eWidth = this.element.width();
        eHeight = this.element.height();
        if (this.stretchToCanvas) {
          eWidth = this.element.width();
          eHeight = this.element.height();
          wRatio = width / eWidth;
          hRatio = height / eHeight;
          minRatio = Math.min(wRatio, hRatio);
          if (minRatio < 1.0) {
            scaleFactor = 1.0 / minRatio;
          } else {
            scaleFactor = 1.0;
          }
          w = width * scaleFactor;
          h = height * scaleFactor;
          if (!this.superZoom) {
            if (this.stockRatio < 1.0) {
              return this.zoomFit();
            } else {
              w = Math.min(this.stockWidth, w);
              h = Math.min(this.stockHeight, h);
              return this.$image.css('background-size', "" + w + "px  " + h + "px");
            }
          }
        } else {
          return this.$image.css('background-size', "" + width + "px  " + height + "px");
        }
      };

      ImageBox.prototype.getXY = function() {
        var coords, elemH, elemW, imageX, imageY;
        imageX = this._backgroundPosition()[0];
        imageY = this._backgroundPosition()[1];
        elemH = this.element.height();
        elemW = this.element.width();
        return coords = {
          "W": this._backgroundSize()[0],
          "H": this._backgroundSize()[1],
          "X1": -1 * imageX,
          "X2": elemW + imageX,
          "Y1": -1 * imageX,
          "Y2": elemH + imageY
        };
      };

      ImageBox.prototype.clearImage = function() {
        this.$image.css('background-position', "0px 0px");
        this.$image.css('background-image', 'none');
        this.$image.css('-webkit-user-select', 'none');
        this.$image.css('-webkit-user-drag', 'none');
        this.$image.css('cursor', 'auto');
        this.$image.css('background-size', "0px 0px");
        this.$image.css('height', this.element.height());
        this.$image.css('width', this.element.width());
        this.$image.css('background-repeat', 'no-repeat no-repeat');
        return this.$image.css('border', 'none');
      };

      return ImageBox;

    })();
  })(window);

}).call(this);
