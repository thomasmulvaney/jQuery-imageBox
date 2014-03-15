# Image Box

jQuery plugin.

## Requirements

* (jQuery >= 1.7.1)[http://jquery.com/]

Optionally, you can use (jquery-mousewheel)[https://github.com/brandonaaron/jquery-mousewheel]


## Demo

[http://wavejumper.github.io/jQuery-imageBox/](http://wavejumper.github.io/jQuery-imageBox/)

## TODO:

* Write tests

## Usage

```javascript
var options = {};
$('#box').imageBox(options);
$('#box').imageBox('setImg', 'http://foo.com/bar.png');
```

## Options

| Name | type | default | description |
| ---- | ----| -------- | ----------- |
| stretchToCanvas | boolean | true | If the image is smaller than the imageBox, the image will be stretched to fit the parent container |

## Methods

| Name       | arguments                 | description                                                                   |
| ---------- | ------------------------- | ----------------------------------------------------------------------------- |
| clearImage | -                         | Clears the image and resets the style of the imageBox                         | 
| getXY      | -                         | Gets the X1, X2, Y1, Y2 co-ords + modified size of image. Useful for cropping | 
| resize     | height, width             | Resizes the image. Height and width must be a number                          | 
| setImg     | img                       | Sets the image of the box. 'img' can either be a hyperlink or a blob          |
