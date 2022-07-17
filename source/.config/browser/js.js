const dayElem = document.getElementsByClassName('date')[0];
const time    = document.getElementsByClassName('time')[0];

const weekdays  = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const timeFunc = function() {
  const date    = new Date();

  let day   = date.getDate();   if (day < 10)   day   = `0${day}`;
  let month = date.getMonth();  if (month < 10) month = `0${month}`;
  const year  = date.getFullYear();

  const weekday = weekdays[date.getDay()];
  const hour    = date.getHours();
  let minute    = date.getMinutes(); if (minute < 10) minute = `0${minute}`;

  let ampm = 'PM'; if (hour < 12) ampm = 'AM';

  dayElem.textContent = `${weekday}. ${day}.${month}.${year}`;
  time.textContent = `${hour%12 ? hour%12 : 12}:${minute} ${ampm}`;
}
setInterval(timeFunc, 1000);
