socket = io.connect()

slidesClass = document.getElementsByClassName('slides')[0]
menu = document.getElementsByClassName('menu')[0]
prevBtn = document.getElementsByClassName('prevBtn')[0]
nextBtn = document.getElementsByClassName('nextBtn')[0]

socket.on 'loaded', (data) ->
  labelLoad data
  socket.json.emit 'count up', slideId: getSlideId()

socket.on 'counter', (data) ->
  counter = document.getElementsByClassName('counter')[0]
  slideId = getSlideId()
  if slideId is data.slideId
    counter.innerHTML = 'now reading : ' + data.count + ' people'

socket.on 'created', (data) ->
  if data.slideKey is getSlideId()
    newLabel = document.createElement 'div'
    newLabel.id = data.id
    newLabel.className = 'label'
    newLabel.style.left = data.x + 'px'
    newLabel.style.top = data.y + 'px'

    # 入力フォームの用意
    inputForm = document.createElement 'form'

    inputText = document.createElement 'textarea'
    inputText.style.cols = '10'
    inputText.style.rows = '3'
    inputForm.appendChild inputText

    okButton = document.createElement 'input'
    okButton.type = 'button'
    okButton.value = 'ok'
    okButton.onclick = ->
      writeText()
    inputForm.appendChild okButton

    # OKされたらテキストを表示し、フォームを消す
    writeText = ->
      labelText = document.createElement 'span'
      str = inputText.value
      str = escapeHTML str
      htmlstr = str.replace /(\n|\r)+/g, '<br />'
      labelText.innerHTML = htmlstr
      newLabel.appendChild labelText

      newLabel.removeChild inputForm

      console.log 'currentSlideNo:%d', currentSlideNo
      socket.json.emit 'text edit',
        id: newLabel.id
        message: htmlstr
      newLabel.onmousedown = (evt) ->
        onDrag evt, @
      newLabel.ondblclick = (evt) ->
        reEdit evt, @
        return false
      slidesClass.addEventListener 'dblclick', addLabel, false
      document.addEventListener 'keydown', handleBodyKeyDown, false

    # 編集をキャンセルした場合の処理
    cancelButton = document.createElement 'input'
    cancelButton.type = 'button'
    cancelButton.value = 'x'
    cancelButton.onclick = ->
      node = newLabel.parentNode
      node.removeChild newLabel
      socket.json.emit 'cancel',
        id: newLabel.id
      slidesClass.addEventListener 'dblclick', addLabel, false
      document.addEventListener 'keydown', handleBodyKeyDown, false

    inputForm.appendChild cancelButton
    # 上記内容をAppend
    newLabel.appendChild inputForm
    document.getElementsByClassName('slide')[data.slideno].appendChild newLabel
    inputText.focus()

socket.on 'created by other', (data) ->
  if data.slideKey is getSlideId()
    newLabel = document.createElement 'div'
    newLabel.id = data.id
    newLabel.className = 'label'
    newLabel.style.left = data.x + 'px'
    newLabel.style.top = data.y + 'px'
    labelText = document.createElement 'span'
    labelText.innerHTML = 'someone writing....'
    newLabel.appendChild labelText
    newLabel.onmousedown = (evt) ->
      onDrag evt, @
    newLabel.ondblclick = (evt) ->
      reEdit evt, @
      return false
  slidesClass.addEventListener 'dblclick', addLabel, false
  document.addEventListener 'keydown', handleBodyKeyDown, false

  document.getElementsByClassName('slide')[data.slideno].appendChild newLabel

socket.on 'text edited', (data) ->
  if data.slideKey is getSlideId()
    label = document.getElementById data.id
    xButtonLabel = label.getElementsByTagName('a')[0]
    labelText = label.getElementsByTagName('span')[0]
    if xButtonLabel
      label.removeChild xButtonLabel
    label.removeChild labelText
    xButton = document.createElement 'a'
    xButton.href = '#'
    xButton.innerHTML = '[x]'
    xButton.onclick = ->
      labelDelete label.id
      return false
    label.appendChild xButton
    labelText.innerHTML = data.message
    label.appendChild labelText

socket.on 'deleted', (data) ->
  label = document.getElementById data.id
  node = label.parentNode
  node.removeChild label

socket.on 'updated', (data) ->
  label = document.getElementById data.id
  label.style.left = data.x + 'px'
  label.style.top = data.y + 'px'

socket.on 'cancelled', (data) ->
  label = document.getElementById data.id
  node = label.parentNode
  node.removeChild label

window.onload = ->
  document.addEventListener 'keydown', handleBodyKeyDown, false
  els = slides
  for el in els
    addClass el, 'slide'
  updateSlideClasses()
  slidesClass.addEventListener 'dblclick', addLabel, false
  createOperationMenu()

# メニューを生成します。
createOperationMenu = ->
  # 表示ボタン
  showButton = document.createElement 'button'
  showButton.type = 'button'
  showButton.innerHTML = '表示'
  showButton.onclick = ->
    showAll()

  # 非表示ボタン
  hideButton = document.createElement 'button'
  hideButton.type = 'button'
  hideButton.innerHTML = '非表示'
  hideButton.onclick = ->
    hideAll()

  menu.appendChild showButton
  menu.appendChild hideButton

  # 前ページボタン
  prevBtn.onclick = (event) ->
    event.preventDefault()
    prevSlide()

  # 次ページボタン
  nextBtn.onclick = (event) ->
    event.preventDefault()
    nextSlide()

# 新しいラベルを追加します。
addLabel = (event) ->
  slidesClass.removeEventListener 'dblclick', addLabel, false
  document.removeEventListener 'keydown', handleBodyKeyDown, false
  layerX = event.layerX
  layerY = event.layerY
  socket.json.emit 'create',
    x: layerX
    y: layerY
    slideno: currentSlideNo-1

# ドラッグされるとラベルを移動する
onDrag = (evt, item) ->
  x = 0
  y = 0

  x = evt.screenX
  y = evt.screenY

  orgX = item.style.left
  orgX = Number orgX.slice(0, -2)
  orgY = item.style.top
  orgY = Number orgY.slice(0, -2)

  slidesClass.addEventListener 'mousemove', mousemove, false
  slidesClass.addEventListener 'mouseup', mouseup, false

  mousemove = (move) ->
    dx = move.screenX - x
    dy = move.screenY - y
    item.style.left = ( orgX + dx ) + 'px'
    item.style.top = ( orgY + dy ) + 'px'
    socket.json.emit 'update',
      id: item.id
      x: orgX + dx
      y: orgY + dy

  mouseup = ->
    slidesClass.removeEventListener 'mousemove', mousemove, false

# ダブルクリックで再編集
reEdit = (evt, oDiv) ->
  str = oDiv.lastChild.innerHTML
  str = escapeHTML str

  oDiv.removeChild oDiv.firstChild
  oDiv.removeChild oDiv.firstChild

  oDiv.ondblclick = -> {}
  slidesClass.removeEventListener 'dblclick', addLabel, false
  oDiv.onmousedown = -> {}

  # フォームを用意し、既に書いてあるテキストを代入
  inputForm = document.createElement 'form'

  inputText = document.createElement 'textarea'
  inputText.style.cols = '10'
  inputText.style.rows = '3'
  str = str.replace /<br\b\/>|<br>/g, '\n'
  inputText.value = str
  inputForm.appendChild inputText

  okButton = document.createElement 'input'
  okButton.type = 'button'
  okButton.value = 'ok'
  okButton.onclick = -> writeText()
  inputForm.appendChild okButton

  # OKされると内容を表示
  writeText = ->
    labelText = document.createElement 'span'
    str = inputText.value
    str = str.replace /(\n|\r)+/g, '<br />'
    labelText.innerHTML = str
    oDiv.appendChild labelText

    oDiv.removeChild inputForm
    socket.json.emit 'text edit'
      id: oDiv.id
      message: str

    oDiv.onmousedown = (evt) ->
      onDrag evt, @

    oDiv.ondblclick = (evt) ->
      reEdit evt,@
      return false

    slidesClass.addEventListener 'dblclick', addLabel, false
    document.addEventListener 'keydown', handleBodyKeyDown, false

  # 編集をキャンセルした場合の処理
  cancelButton = document.createElement 'input'
  cancelButton.type = 'button'
  cancelButton.value = 'x'
  cancelButton.onclick = ->
    xButton = document.createElement 'a'
    xButton.href = '#'
    xButton.innerHTML = '[x]'
    xButton.onclick = ->
      labelDelete newLabel.id
      return false
    oDiv.appendChild xButton

    labelText = document.createElement 'span'
    labelText.innerHTML = str
    oDiv.appendChild labelText

    oDiv.removeChild inputForm

    oDiv.onmousedown = (evt) ->
      onDrag evt, @
    oDiv.ondblclick = (evt) ->
      reEdit evt,@
      return false

    slidesClass.addEventListener 'dblclick', addLabel, false
    document.addEventListener 'keydown', handleBodyKeyDown, false

  inputForm.appendChild cancelButton

  # 上記内容をAppend
  oDiv.appendChild inputForm

  inputText.focus()

# ラベルをロードします。
labelLoad = (data) ->
  newLabel = document.createElement 'div'

  newLabel.className = 'label'
  newLabel.id = data._id
  newLabel.style.left = data.x + 'px'
  newLabel.style.top = data.y + 'px'
  document.getElementsByClassName('slide')[data.slideno].appendChild newLabel

  xButton = document.createElement 'a'
  xButton.href = '#'
  xButton.innerHTML = '[x]'
  xButton.onclick = ->
    labelDelete newLabel.id
    return false
  newLabel.appendChild xButton

  labelText = document.createElement 'span'
  labelText.innerHTML = data.message
  newLabel.appendChild labelText

  newLabel.onmousedown = (evt) ->
    onDrag evt, @

  newLabel.ondblclick = (evt) ->
    reEdit evt, @
    return false

# 現在表示されているページのスライドIDを取得します。
getSlideId = ->
  url = location.href
  start = url.lastIndexOf('/')+1
  end = url.indexOf '#'
  if start < end
    slideId = url.substring start, end
    console.log slideId
    return slideId
  else
    return 'default'

# 文字列をHTMLエスケープします。
escapeHTML = (str) ->
  return str.replace(/&/g, '&amp').replace(/'/g, '&quot').replace(/</g, '&lt').replace(/>/g, '&gt')

# ラベルを削除します。
labelDelete = (id) ->
  socket.json.emit 'delete',
    id: id

# ラベルを保存します。
labelSave = ->
  # ラベルのセーブ

# すべてのラベルを表示します。
showAll = ->
  labels = document.getElementsByClassName 'label'
  console.log labels
  for label in labels
    console.log label
    label.style.display=''

# すべてのラベルを非表示にします。
hideAll = ->
  labels = document.getElementsByClassName 'label'
  console.log labels.length
  for label in labels
    console.log label
    label.style.display='none'

