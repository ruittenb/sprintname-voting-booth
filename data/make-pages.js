
const letters = [ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'W', 'Y', 'Z' ];

const fortnight = 1000 * 60 * 60 * 24 * 14; // milliseconds in 2 weeks

let date = new Date("2021-10-26T04:00:00.000+02:00");
let id = 154;

letters.forEach((l) => {
    console.log(`{ "generation": 8, "id":${id++}, "letter": "${l}", "open": true, "startDate": "${date.toISOString()}" },`);
    date = new Date(date.getTime() + fortnight);
});

