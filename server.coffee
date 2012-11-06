
###
 Module dependencies.
###

express = require 'express'
routes = require './routes'
io = require 'socket.io'
mongoose = require 'mongoose'

app = module.exports = express.createServer()
counter = 0
mongoUri = 'mongodb://127.0.0.1/nodeslide'
Schema = mongoose.Schema
commentSchema = new Schema
  slideno :Number
  message :String
  slideKey:String
  x :Number
  y :Number

slideKey = 'default'
socketIds = []
slideMap = []

# Configuration

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static  __dirname + '/public'
  mongoose.connect mongoUri

Comment = mongoose.model 'Comment', commentSchema

app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure 'production', ->
  app.use express.errorHandler()

# Routes

app.get '/favicon.ico', (req, res) ->
  res.render 'favicon.ico', {}

app.get '/:id?', (req, res) ->
  console.log req.params.id
  if !req.params.id
    slideKey = 'default'
  else
    slideKey = req.params.id

  counter = slideMap[slideKey]
  if !counter
    slideMap[slideKey] = 0

  if slideKey != 'default'
    res.render slideKey, slideId: slideKey
  else
    res.render 'index', slideId: 'default'

app.listen process.env.PORT || 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

# Process
io = io.listen app
io.sockets.on 'connection', (socket) ->

  socket.on 'count up', (data) ->
    socket.set 'slideId', data.slideId, ->
      if socketIds.indexOf socket.id  < 0
        socketIds.push socket.id
        console.log socket.id
        count = slideMap[data.slideId]
        count++
        slideMap[data.slideId] = count
        io.sockets.emit 'counter', count : count, slideId: data.slideId

  socket.on 'disconnect', ->
    console.log 'disconnect'
    index = socketIds.indexOf socket.id
    socketIds.splice index, 1

    socket.get 'slideId', (err, slideId) ->
      if !err
        console.log "slideId disconnect" + slideId
        count = slideMap[slideId]
        count--
        slideMap[slideId] = count
        io.sockets.emit 'counter', count : count, slideId: slideId
      else
        console.log err

  Comment.find slideKey: slideKey, (err,docs) ->
    if !err
      i = 0
      for doc in docs
        console.log doc
        if doc.message
          socket.emit 'loaded', doc
        else
          Comment.findById doc.id, (err, comment) ->
            if !err
              comment.remove()
            else
              console.log err
        i++
    else
      console.log err

  socket.on 'create', (data) ->
    console.log data
    if data
      console.log "Data : %s", data.message
      console.log "Data : %s", data.slideno

      comment = new Comment()
      comment.slideno = data.slideno
      comment.x = data.x
      comment.y = data.y
      comment.slideKey = slideKey
      console.log comment
      comment.save (err, doc) ->
        console.log 'saved: %s', doc.id
        if !err
          socket.emit 'created', id: doc.id, slideno: doc.slideno, x: doc.x, y:doc.y, slideKey:doc.slideKey
          socket.broadcast.emit 'created by other', id: doc.id, slideno: doc.slideno, x: doc.x, y:doc.y, slideKey:doc.slideKey
        else
          console.log err

  socket.on 'text edit', (data) ->
    if data && data.message
      Comment.findById data.id, (err, comment) ->
        if !err
          if data.message != null
            comment.message = data.message
          comment.save (err) ->
            if !err
              socket.emit 'text edited', id: comment.id, slideno: comment.slideno, x: comment.x, y: comment.y, message: comment.message, slideKey:comment.slideKey
              socket.broadcast.emit 'text edited', id: comment.id, slideno: comment.slideno, x: comment.x, y: comment.y, message: comment.message, slideKey:comment.slideKey
            else
              console.log err

  socket.on 'delete', (data) ->
    console.log data
    if data
      Comment.findById data.id, (err, comment) ->
        if !err && comment
          comment.remove()
          socket.emit 'deleted', id: data.id
          socket.broadcast.emit 'deleted', id: data.id
        else
          console.log err

  socket.on 'cancel', (data) ->
    if data
      Comment.findById data.id, (err, comment) ->
        if !err && comment
          comment.remove()
          socket.broadcast.emit 'cancelled', id: data.id
        else
          console.log err

  socket.on 'update', (data) ->
     if data
       Comment.findById data.id, (err, comment) ->
         if !err && comment
           comment.x = data.x
           comment.y = data.y
           comment.save (err) ->
             if !err
               socket.emit 'updated', id: comment.id, x: comment.x, y: comment.y
               socket.broadcast.emit 'updated', id: comment.id, x: comment.x, y: comment.y
             else
               console.log err
         else
           console.log err

