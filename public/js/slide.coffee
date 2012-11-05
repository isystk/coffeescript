# 現在表示しているページ番号を取得します
getCurrentSlide = ->
  url = location.href

  start = url.lastIndexOf '#slide'
  if start >= 0
    slideNum = url.substring start+6
    console.log slideNum
    return slideNum
  else
    return 1

currentSlideNo = getCurrentSlide()
slides = document.getElementsByClassName 'slide'

# スペース区切りの文字列を配列に変換する
spaces = /\s+/
a1 = ['']
str2array = (s) ->
  if typeof s is 'string' or s instanceof String
    if s.indexOf(' ') < 0
      a1[0] = s
      return a1
    else
      return s.split spaces
  return s

# スペースを除去する
trim = (str) ->
  return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

# Class属性を追加する
addClass = (node, classStr) ->
  classStr = str2array classStr
  cls = ' ' + node.className + ' '
  for c in classStr
    if c and cls.indexOf ' ' + c + ' ' < 0
      cls += c + ' '
  node.className = trim cls

# Class属性を除去する
removeClass = (node, classStr) ->
  cls
  if classStr isnt undefined
    classStr = str2array classStr
    cls = ' ' + node.className + ' '
    for c in classStr
      cls = cls.replace ' ' + c + ' ', ' '
    cls = trim cls
  else
    cls = ''
  if node.className isnt cls
    node.className = cls

getSlideEl = (slideNo) ->
  if slideNo > 0
    return slides[slideNo - 1]
  else
    return null

changeSlideElClass = (slideNo, className) ->
  el = getSlideEl slideNo
  if el
    removeClass el, 'far-past past current future far-future'
    addClass el, className

updateSlideClasses = ->
  window.location.hash = 'slide' + currentSlideNo
  changeSlideElClass currentSlideNo - 2, 'far-past'
  changeSlideElClass currentSlideNo - 1, 'past'
  changeSlideElClass currentSlideNo, 'current'
  changeSlideElClass currentSlideNo + 1, 'future'
  changeSlideElClass currentSlideNo + 2, 'far-future'

# 次ページ処理
nextSlide = ->
  if currentSlideNo < slides.length
    currentSlideNo++
  updateSlideClasses()

# 前ページ処理
prevSlide = ->
  if currentSlideNo > 1
    currentSlideNo--
  updateSlideClasses()

# キーボード押下処理
handleBodyKeyDown = (event) ->
  switch event.keyCode
    # 左矢印押下時
    when 37
      prevSlide()
    # 右矢印押下時
    when 39
      nextSlide()

# コメントを表示します。
showAll = ->
  labels = document.getElementsByClassName 'label'
  console.log labels
  for label in labels
    label.style.display = ''

# コメントを非表示にします。
hideAll = ->
  labels = document.getElementsByClassName 'label'
  console.log labels
  for label in labels
    label.style.display = 'none'

# ソースコードをハイライト表示
( ->
  prettify = ->
    prettyPrint()
  if window.addEventListener
    window.addEventListener 'load', prettify, false
  else if window.attachEvent
    window.attachEvent 'onload', prettify
  else
    window.onload = prettify
)()

