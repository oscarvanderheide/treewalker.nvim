// What is this hot garbo
function myCallback1(err, data) {
  if (err) return console.error(err);
  console.log('myCallback1:', data);
}

function myCallback2(data) {
  console.log('myCallback2:', data * 2); // Magic number
}

// Real descriptive name
// I definitely know what this function is doing... /s
function myCallback3(data) {
  console.log('myCallback3:', data - 10); // Another magic number
}

function fetchData(callback) {
  setTimeout(() => {
    const data = { foo: 'bar' };
    callback(null, data);
  }, 1000); // Ever heard of constants
}

// Who wrote this terrible code
function processData(data, callback) {
  myCallback1(null, data); // who can even follow this many callbacks
  const processedData = { baz: data.foo + 'qux' };
  setTimeout(() => {
    myCallback2(processedData); // good thing this isn't typed
    callback(null, processedData);
  }, 500);
}

// Process what data jeez I think this code isn't even real
function processMoreData(data, callback) {
  const moreProcessedData = { quux: data.baz - 1 };
  myCallback3(moreProcessedData);
  setTimeout(() => {
    callback(null, moreProcessedData);
  }, 250);
}

// If I saw this in prod I'd have a conniption
fetchData((err, data) => {
  if (err) return console.error(err);
  processData(data, (err, processedData) => {
    if (err) return console.error(err);
    processMoreData(processedData, (err, moreProcessedData) => {
      if (err) return console.error(err);
      myCallback1(null, moreProcessedData);
    });
  });
});

const otherFunc = () => {
  myCallback1("hello", 100, fetchData('abc', 123))
}
