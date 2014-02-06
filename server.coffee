restify = require 'restify'
swagger = require 'swagger-doc'

server = restify.createServer()
server.pre restify.pre.userAgentConnection()
server.use restify.acceptParser server.acceptable # respond correctly to accept headers
server.use restify.queryParser() # parse query variables
server.use restify.fullResponse() # set CORS, eTag, other common headers
server.use restify.gzipResponse()

jumpingjacks = 0
timeout = 1 * 60 * 1000 # Stop counting jumpingjacks every minute
timer = {}

coinflip = -> Math.round Math.random()

server.get  "/calibrated", (req, res) ->
  res.send 200, coinflip()

server.get  "/jumpingjacks", (req, res) ->
  coinflip() and jumpingjacks++
  res.send 200, jumpingjacks

server.get  "/start", (req, res) ->
  clearTimeout @timer if timer isnt {}
  @timer = setTimeout (-> jumpingjacks = 0), timeout
  jumpingjacks = 0
  res.send jumpingjacks

swagger.configure server
docs = swagger.createResource '/docs'
docs.get "/calibrated", "Ask if the camera can see a bounding box",
  nickname: "getCalibrated"

docs.get "/start", "Reset the jumpingjacks counter to 0 and start counting",
  nickname: "getStart"

docs.get "/jumpingjacks", "How many jumping jacks have we seen since start?",
  nickname: "getJumpingjacks"

server.get /\/*/, restify.serveStatic directory: './static', default: 'index.html', charSet: 'UTF-8'

server.listen process.env.PORT or 5000, ->
  console.log "[%s] #{server.name} listening at #{server.url}", process.pid
