socket = io.connect()

slidesClass = document.getElementsByClassName('slides')[0]
operation = document.getElementsByClassName('operation')[0]

socket.on 'loaded', (data) ->
  labelLoad data
  socket.json.emit 'count up', slideId: getSlideId()

socket.on 'counter', (data) ->
  counter = document.getElementsByClassName('counter')[0]
  slideId = getSlideId()
  if slideId == data.slideId
    counter.innerHTML = 'now reading : ' + data.count + ' people'

socket.on 'created', (data) ->
  if data.slideKey == getSlideId()
    newLabel = document.createElement('DIV')
    newLabel.id = data.id
    newLabel.className = 'label'
    newLabel.style.left = data.x + 'px'
    newLabel.style.top = data.y + 'px'
    # 入力フォームの用意
    inputForm = document.createElement('FORM')

    inputText = document.createElement('TEXTAREA')
    inputText.style.cols = '10'
    inputText.style.rows = '3'
    inputForm.appendChild inputText

    okButton = document.createElement 'INPUT'
    okButton.type = 'button'
    okButton.value = 'ok'
    okButton.onclick = ->
      writeText()
    inputForm.appendChild okButton
    # OKされたらテキストを表示し、フォームを消す
    writeText = ->
      labelText = document.createElement 'SPAN'
      str = inputText.value
      str = escapeHTML str
      htmlstr = str.replace(/(\n|\r)+/g, '<br />')
      labelText.innerHTML = htmlstr
      newLabel.appendChild labelText

      newLabel.removeChild inputForm

      console.log 'currentSlideNo:%d', currentSlideNo
      socket.json.emit 'text edit', {id: newLabel.id, message: htmlstr}
      newLabel.onmousedown = (evt) ->
        onDrag evt, this
      newLabel.ondblclick = (evt) ->
        reEdit evt, this
        return false
      slidesClass.addEventListener 'dblclick', addLabel, false
      document.addEventListener 'keydown', handleBodyKeyDown, false

    # 編集をキャンセルした場合の処理
    cancelButton = document.createElement 'INPUT'
    cancelButton.type = 'button'
    cancelButton.value = 'x'
    cancelButton.onclick = ->
      node = newLabel.parentNode
      node.removeChild(newLabel)
      socket.json.emit('cancel', {id: newLabel.id})
      slidesClass.addEventListener 'dblclick', addLabel, false
      document.addEventListener 'keydown', handleBodyKeyDown, false

    inputForm.appendChild cancelButton
    # 上記内容をAppend
    newLabel.appendChild inputForm
    document.getElementsByClassName('slide')[data.slideno].appendChild(newLabel)
    inputText.focus()

socket.on 'created by other', (data) ->
  if data.slideKey == getSlideId()
    newLabel = document.createElement('DIV')
    newLabel.id = data.id
    newLabel.className = 'label'
    newLabel.style.left = data.x + 'px'
    newLabel.style.top = data.y + 'px'
    labelText = document.createElement('SPAN')
    labelText.innerHTML = 'someone writing....'
    newLabel.appendChild(labelText)
    newLabel.onmousedown = (evt) ->
      onDrag evt, this
    newLabel.ondblclick = (evt) ->
      reEdit evt, this
      return false
  slidesClass.addEventListener 'dblclick', addLabel, false
  document.addEventListener 'keydown', handleBodyKeyDown, false

  document.getElementsByClassName('slide')[data.slideno].appendChild(newLabel)

socket.on 'text edited', (data) ->
  if data.slideKey == getSlideId()
    label = document.getElementById(data.id)
    xButtonLabel = label.getElementsByTagName('A')[0]
    labelText = label.getElementsByTagName('SPAN')[0]
    if xButtonLabel
      label.removeChild xButtonLabel
    label.removeChild labelText
    xButton = document.createElement 'A'
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

createOperationMenu = ->
  showButton = document.createElement 'BUTTON'
  showButton.type = 'button'
  showButton.innerHTML = 'show'
  # hideButton.addEventListener 'click', hideAll, false
  showButton.onclick = ->
    showAll()

  hideButton = document.createElement 'BUTTON'
  hideButton.type = 'button'
  hideButton.innerHTML = 'hide'
  # hideButton.addEventListener 'click', hideAll, false
  hideButton.onclick = ->
    hideAll()

  previousButton = document.createElement 'BUTTON'
  previousButton.type = 'button'
  previousButton.innerHTML = '< previous'
  # hideButton.addEventListener 'click', hideAll, false
  previousButton.onclick = ->
    prevSlide()

  nextButton = document.createElement 'BUTTON'
  nextButton.type = 'button'
  nextButton.innerHTML = 'next >'
  # hideButton.addEventListener 'click', hideAll, false
  nextButton.onclick = ->
    nextSlide()
  colorSelector = document.createElement 'SELECT'
  yellowOption = document.createElement 'OPTION'
  yellowOption.value = 'yellow'
  yellowOption.innerHTML = 'yellow'
  yellowOption.onselect = ->
    console.log 'yellow'
  redOption = document.createElement 'OPTION'
  redOption.value = 'red'
  redOption.innerHTML = 'red'
  colorSelector.appendChild yellowOption
  colorSelector.appendChild redOption

  operation.appendChild showButton
  operation.appendChild hideButton
  operation.appendChild previousButton
  operation.appendChild nextButton
  # operation.appendChild colorSelector

addLabel = (event) ->
  # 新しいラベルの追加
  slidesClass.removeEventListener 'dblclick', addLabel, false
  document.removeEventListener 'keydown', handleBodyKeyDown, false
  layerX = event.layerX
  layerY = event.layerY
  socket.json.emit 'create', {x: layerX, y: layerY, slideno: currentSlideNo-1}

onDrag = (evt, item) ->
  # ドラッグされるとラベルを移動する
  x = 0
  y = 0

  x = evt.screenX
  y = evt.screenY

  orgX = item.style.left
  orgX = Number(orgX.slice(0, -2))
  orgY = item.style.top
  orgY = Number(orgY.slice(0, -2))

  slidesClass.addEventListener('mousemove', mousemove, false)
  slidesClass.addEventListener('mouseup', mouseup, false)

  mousemove = (move) ->
    dx = move.screenX - x
    dy = move.screenY - y
    item.style.left = ( orgX + dx ) + 'px'
    item.style.top = ( orgY + dy ) + 'px'
    socket.json.emit 'update', {id: item.id,x: orgX + dx, y: orgY + dy}

  mouseup = ->
    slidesClass.removeEventListener 'mousemove', mousemove, false

reEdit = (evt, oDiv) ->
  # ダブルクリックで再編集
  str = oDiv.lastChild.innerHTML
  str = escapeHTML(str)

  oDiv.removeChild(oDiv.firstChild)
  oDiv.removeChild(oDiv.firstChild)

  oDiv.ondblclick = -> {}
  slidesClass.removeEventListener('dblclick', addLabel, false)
  oDiv.onmousedown = -> {}

  # フォームを用意し、既に書いてあるテキストを代入
  inputForm = document.createElement('FORM')

  inputText = document.createElement('TEXTAREA')
  inputText.style.cols = '10'
  inputText.style.rows = '3'
  str = str.replace(/<br\b\/>|<br>/g, '\n')
  inputText.value = str
  inputForm.appendChild inputText

  okButton = document.createElement 'INPUT'
  okButton.type = 'button'
  okButton.value = 'ok'
  okButton.onclick = -> writeText()
  inputForm.appendChild okButton

  # OKされると内容を表示
  writeText = ->

    labelText = document.createElement('SPAN')
    str = inputText.value
    str = str.replace(/(\n|\r)+/g, '<br />')
    labelText.innerHTML = str
    oDiv.appendChild(labelText)

    oDiv.removeChild(inputForm)
    socket.json.emit 'text edit', {id: oDiv.id, message: str}

    oDiv.onmousedown = (evt) ->
      onDrag evt, this
    oDiv.ondblclick = (evt) ->
      reEdit evt,this
      return false

    slidesClass.addEventListener('dblclick', addLabel, false)
    document.addEventListener('keydown', handleBodyKeyDown, false)

  # 編集をキャンセルした場合の処理
  cancelButton = document.createElement 'INPUT'
  cancelButton.type = 'button'
  cancelButton.value = 'x'
  cancelButton.onclick = ->
    xButton = document.createElement 'A'
    xButton.href = '#'
    xButton.innerHTML = '[x]'
    xButton.onclick = ->
      labelDelete newLabel.id
      return false
    oDiv.appendChild xButton

    labelText = document.createElement 'SPAN'
    labelText.innerHTML = str
    oDiv.appendChild labelText

    oDiv.removeChild inputForm

    oDiv.onmousedown = (evt) ->
      onDrag evt, this
    oDiv.ondblclick = (evt) ->
      reEdit evt,this
      return false

    slidesClass.addEventListener 'dblclick', addLabel, false
    document.addEventListener 'keydown', handleBodyKeyDown, false
  inputForm.appendChild cancelButton

  # 上記内容をAppend
  oDiv.appendChild inputForm

  inputText.focus()

labelLoad = (data) ->
  # ラベルのロード
  newLabel = document.createElement 'div'

  newLabel.className = 'label'
  newLabel.id = data._id
  newLabel.style.left = data.x + 'px'
  newLabel.style.top = data.y + 'px'
  document.getElementsByClassName('slide')[data.slideno].appendChild(newLabel)

  xButton = document.createElement 'A'
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
    onDrag evt, this

  newLabel.ondblclick = (evt) ->
    reEdit evt, this
    return false

getSlideId = ->
  url = location.href

  start = url.lastIndexOf('/')+1
  end = url.indexOf('#')
  if start < end
    slideId = url.substring start, end
    console.log slideId
    return slideId
  else
    return 'default'

escapeHTML = (str) ->
  return str.replace(/&/g, '&amp').replace(/'/g, '&quot').replace(/</g, '&lt').replace(/>/g, '&gt')


labelDelete = (id) ->
  socket.json.emit 'delete',
    id: id

labelSave = ->
  # ラベルのセーブ

showAll = ->
  labels = document.getElementsByClassName 'label'
  console.log labels
  for label in labels
    console.log label
    label.style.display=''

hideAll = ->
  labels = document.getElementsByClassName 'label'
  console.log labels.length
  for label in labels
    console.log label
    label.style.display='none'

