let axios = require('axios')

let APPID = "061f24cf3cde2f60644a8240302983f2"

let def weather_url_by_lat_lon(lat, lon)
  "https://cors-anywhere.herokuapp.com/http://api.openweathermap.org/data/2.5/weather?lat={ encodeURI(lat) }&lon={ encodeURI(lon) }&units=metric&APPID={ APPID }&mode=json"

let def weather_url_by_name(location)
  "https://cors-anywhere.herokuapp.com/http://api.openweathermap.org/data/2.5/weather?q={ encodeURI(location) }&units=metric&APPID={ APPID }&mode=json"

tag App
  def onmapclicked(event)
    let native_event = event.event
    let el = native_event:target
    let rect = el.getBoundingClientRect()
    let offset_x = native_event:pageX - rect:left
    let offset_y = native_event:pageY - rect:top
    let perc_x = offset_x / rect:width
    let perc_y = offset_y / rect:height
    let lon = -180 + 360 * perc_x
    let lat = 90 - 180 * perc_y
    let url = weather_url_by_lat_lon(lat, lon)
    fetch_weather_data(url)

  def fetch_weather_data(url)
    axios.get(url)
      .then do |response|
        Imba.commit
        @data = response:data
      .catch(do null)

  def setup
    if window:navigator:geolocation
      window:navigator:geolocation.getCurrentPosition do |pos|
        let c = pos:coords
        let url = weather_url_by_lat_lon(c:latitude, c:longitude)
        fetch_weather_data(url)
    else
      console.log("There is no geolocation available")
      let url = weather_url_by_name("London, UK")
      fetch_weather_data(url)

  def night
    @data && icon.endsWith("d")

  def icon
    @data && @data:weather[0]:icon

  def icon_png
    @data && "http://openweathermap.org/img/w/{ icon }.png"

  def render
    <self.page data-weather=(icon && parseInt(icon, 10))>
      <div.weather-box .night=night>
        <img.map src="earth.jpg" :click.onmapclicked>
        if @data
          <h1.header>
            "{@data:name} ({@data:coord:lat}, {@data:coord:lon})"
          <h2.temperature>
            "{ Math.round(data:main:temp) } C"
          <img.weather-icon src=icon_png>
        else
          <div>
            "Click on the map to get the weather"

Imba.mount <App>
