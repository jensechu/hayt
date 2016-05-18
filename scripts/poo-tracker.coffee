Redis = require 'redis'
Url = require 'url'

info = Url.parse process.env.POO_REDIS_URL or "redis://localhost:6379/0"
redis_client = Redis.createClient(info.port, info.hostname)
redis_client.auth info.auth.split(":")[1] if info.auth

module.exports = (robot) ->
  POO_TRACKER_KEY = "poops"
  POO_LATEST_KEY = "poops:latest_message"

  checkRedisForShit = ->
    redis_client.rpop POO_TRACKER_KEY, (err, reply) ->
      return console.error("Failed lindex with key '#{POO_TRACKER_KEY}' and index -1: #{err}") if err
      return if reply == null

      room = process.env.HUBOT_IRC_ROOMS or "#arrakis"
      e = room: room
      robot.send e, reply
      redis_client.set POO_LATEST_KEY, reply

  robot.respond /poo tracker( me)?/i, (res) ->
    redis_client.get POO_LATEST_KEY, (err, reply) ->
      return console.error("Failed get with key '#{POO_TRACKER_KEY}': #{err}") if err
      return if reply == null
      return res.send "Latest poo: #{reply}"

  setInterval ->
    checkRedisForShit()
  , 1000
