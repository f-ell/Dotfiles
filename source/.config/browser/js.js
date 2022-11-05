const dayElem = document.getElementsByClassName('date')[0];
const time    = document.getElementsByClassName('time')[0];

const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const pad = function(num, len, sym) {
  return num.toString().padStart(len, sym);
}

const getTime = function() {
  const date  = new Date();

  let day     = pad(date.getDate(), 2, '0');
  let month   = pad(date.getMonth(), 2, '0');
  const year  = date.getFullYear();

  const weekday = weekdays[date.getDay()];
  const hour    = date.getHours();
  let minute    = pad(date.getMinutes(), 2, '0');

  hour < 12 ? ampm = 'AM' : ampm = 'PM';

  dayElem.textContent = `${weekday}. ${day}.${month}.${year}`;
  time.textContent = `${hour%12 ? hour%12 : 12}:${minute} ${ampm}`;
}
setInterval(getTime, 1000);
