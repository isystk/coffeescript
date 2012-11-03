// Generated by CoffeeScript 1.4.0
var a1, addClass, changeSlideElClass, currentSlideNo, getCurrentSlide, getSlideEl, handleBodyKeyDown, hideAll, nextSlide, prevSlide, removeClass, showAll, slides, spaces, str2array, trim, updateSlideClasses;

getCurrentSlide = function() {
  var slideNum, start, url;
  url = location.href;
  start = url.lastIndexOf('#slide');
  if (start >= 0) {
    slideNum = url.substring(start + 6);
    console.log(slideNum);
    return slideNum;
  } else {
    return 1;
  }
};

currentSlideNo = getCurrentSlide();

slides = document.getElementsByClassName('slide');

spaces = /\s+/;

a1 = [''];

str2array = function(s) {
  if (typeof s === 'string' || s instanceof String) {
    if (s.indexOf(' ') < 0) {
      a1[0] = s;
      return a1;
    } else {
      return s.split(spaces);
    }
  }
  return s;
};

trim = function(str) {
  return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
};

addClass = function(node, classStr) {
  var c, cls, _i, _len;
  classStr = str2array(classStr);
  cls = ' ' + node.className + ' ';
  for (_i = 0, _len = classStr.length; _i < _len; _i++) {
    c = classStr[_i];
    if (c && cls.indexOf(' ' + c + ' ') < 0) {
      cls += c + ' ';
    }
  }
  return node.className = trim(cls);
};

removeClass = function(node, classStr) {
  cls;

  var c, cls, _i, _len;
  if (classStr !== void 0) {
    classStr = str2array(classStr);
    cls = ' ' + node.className + ' ';
    for (_i = 0, _len = classStr.length; _i < _len; _i++) {
      c = classStr[_i];
      cls = cls.replace(' ' + c + ' ', ' ');
    }
    cls = trim(cls);
  } else {
    cls = '';
  }
  if (node.className !== cls) {
    return node.className = cls;
  }
};

getSlideEl = function(slideNo) {
  if (slideNo > 0) {
    return slides[slideNo - 1];
  } else {
    return null;
  }
};

changeSlideElClass = function(slideNo, className) {
  var el;
  el = getSlideEl(slideNo);
  if (el) {
    removeClass(el, 'far-past past current future far-future');
    return addClass(el, className);
  }
};

updateSlideClasses = function() {
  window.location.hash = 'slide' + currentSlideNo;
  changeSlideElClass(currentSlideNo - 2, 'far-past');
  changeSlideElClass(currentSlideNo - 1, 'past');
  changeSlideElClass(currentSlideNo, 'current');
  changeSlideElClass(currentSlideNo + 1, 'future');
  return changeSlideElClass(currentSlideNo + 2, 'far-future');
};

nextSlide = function() {
  if (currentSlideNo < slides.length) {
    currentSlideNo++;
  }
  return updateSlideClasses();
};

prevSlide = function() {
  if (currentSlideNo > 1) {
    currentSlideNo--;
  }
  return updateSlideClasses();
};

handleBodyKeyDown = function(event) {
  switch (event.keyCode) {
    case 37:
      return prevSlide();
    case 39:
      return nextSlide();
  }
};

showAll = function() {
  var label, labels, _i, _len, _results;
  labels = document.getElementsByClassName('label');
  console.log(labels);
  _results = [];
  for (_i = 0, _len = labels.length; _i < _len; _i++) {
    label = labels[_i];
    _results.push(label.style.display = '');
  }
  return _results;
};

hideAll = function() {
  var label, labels, _i, _len, _results;
  labels = document.getElementsByClassName('label');
  console.log(labels);
  _results = [];
  for (_i = 0, _len = labels.length; _i < _len; _i++) {
    label = labels[_i];
    _results.push(label.style.display = 'none');
  }
  return _results;
};

(function() {
  var prettify;
  prettify = function() {
    return prettyPrint();
  };
  if (window.addEventListener) {
    return window.addEventListener('load', prettify, false);
  } else if (window.attachEvent) {
    return window.attachEvent('onload', prettify);
  } else {
    return window.onload = prettify;
  }
})();
