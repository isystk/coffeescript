###
currentSlideNo = getCurrentSlide()
slides = document.getElementsByClassName('slide')

spaces = /\s+/, a1 = [""]

str2array = (s) -> {
  if (typeof s === "string" || s instanceof String) {
    if (s.indexOf(" ") < 0) {
      a1[0] = s
      return a1
    } else {
      return s.split(spaces)
    }
  }
  return s
}

trim = (str) -> {
  return str.replace(/^\s\s* /, '').replace(/\s\s*$/, '')
}

addClass = (node, classStr) -> {
  classStr = str2array(classStr)
  cls = " " + node.className + " "
  for (i = 0, len = classStr.length, c i < len ++i) {
    c = classStr[i]
    if (c && cls.indexOf(" " + c + " ") < 0) {
      cls += c + " "
    }
  }
  node.className = trim(cls)
}

removeClass = (node, classStr) -> {
  cls
  if (classStr !== undefined) {
    classStr = str2array(classStr)
    cls = " " + node.className + " "
    for (i = 0, len = classStr.length i < len ++i) {
      cls = cls.replace(" " + classStr[i] + " ", " ")
    }
    cls = trim(cls)
  } else {
    cls = ""
  }
  if (node.className != cls) {
    node.className = cls
  }
}

getSlideEl = (slideNo) -> {
  if (slideNo > 0) {
    return slides[slideNo - 1]
  } else {
    return null
  }
}

changeSlideElClass = (slideNo, className) -> {
  el = getSlideEl(slideNo)

  if (el) {
    removeClass(el, 'far-past past current future far-future')
    addClass(el, className)
  }
}

updateSlideClasses = -> {
  window.location.hash = "slide" + currentSlideNo
  changeSlideElClass(currentSlideNo - 2, 'far-past')
  changeSlideElClass(currentSlideNo - 1, 'past')
  changeSlideElClass(currentSlideNo, 'current')
  changeSlideElClass(currentSlideNo + 1, 'future')
  changeSlideElClass(currentSlideNo + 2, 'far-future')
}

nextSlide = -> {
  if (currentSlideNo < slides.length) {
    currentSlideNo++
  }
  updateSlideClasses()
}

prevSlide = -> {
  if (currentSlideNo > 1) {
    currentSlideNo--
  }
  updateSlideClasses()
}

handleBodyKeyDown = (event) -> {
  switch event.keyCode
    when 37
      prevSlide()
    when 39
      nextSlide()
}

getCurrentSlide -> {
  url = location.href

  start = url.lastIndexOf('#slide')
  if (start >= 0) {
    slideNum = url.substring(start+6)
    console.log(slideNum)
    return slideNum
  } else {
    return 1
  }
}

# コメントを表示します。
showAll -> {
  labels = document.getElementsByClassName("label")
  console.log(labels)
  for (label in labels) {
    label.style.display=''
  }
}

# コメントを非表示にします。
hideAll -> {
  labels = document.getElementsByClassName("label")
  console.log(labels)
  for (label in labels) {
    label.style.display='none'
  }
}

# ソースコードをハイライト表示
( -> {
  prettify -> {
    prettyPrint()
  }
  if (window.addEventListener) {
    window.addEventListener("load", prettify, false)
  } else if (window.attachEvent) {
    window.attachEvent("onload", prettify)
  } else {
    window.onload = prettify
  }
})()

###
