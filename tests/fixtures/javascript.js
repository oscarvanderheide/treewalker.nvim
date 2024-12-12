function myCallback1(err, data) {
  if (err) return console.error(err);
  console.log('myCallback1:', data);
}

function myCallback2(data) {
  console.log('myCallback2:', data * 2);
}

function myCallback3(data) {
  console.log('myCallback3:', data - 10);
}

// Define some asynchronous functions that use callbacks

function fetchData(callback) {
  setTimeout(() => {
    const data = { foo: 'bar' };
    callback(null, data);
  }, 1000);
}

function processData(data, callback) {
  myCallback1(null, data); // callback within a callback!
  const processedData = { baz: data.foo + 'qux' };
  setTimeout(() => {
    myCallback2(processedData); // another callback
    callback(null, processedData);
  }, 500);
}

function processMoreData(data, callback) {
  const moreProcessedData = { quux: data.baz - 1 };
  myCallback3(moreProcessedData); // yet another callback
  setTimeout(() => {
    callback(null, moreProcessedData);
  }, 250);
}

// Call the asynchronous functions with callbacks

fetchData((err, data) => {
  if (err) return console.error(err);
  processData(data, (err, processedData) => {
    if (err) return console.error(err);
    processMoreData(processedData, (err, moreProcessedData) => {
      if (err) return console.error(err);
      myCallback1(null, moreProcessedData); // final callback
    });
  });
});

