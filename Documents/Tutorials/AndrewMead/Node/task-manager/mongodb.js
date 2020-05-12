//CRUD create read update delete

// const mongodb = require('mongodb');
// const MongoClient = mongodb.MongoClient;
// const ObjectID = mongodb.ObjectID

const { MongoClient, ObjectID } = require('mongodb');

const connectionURL = 'mongodb://127.0.0.1:27017';
const databaseName = 'task-manager';

const id = new ObjectID();

// console.log(id.id.length);
// console.log(id.getTimestamp());
// console.log(id.toHexString().length);

MongoClient.connect(
  connectionURL,
  { useNewUrlParser: true },
  (error, client) => {
    if (error) {
      return console.log('Unable to connect to database!');
    }
    // console.log('Connected correctly!');
    const db = client.db(databaseName);

    // db.collection('users').findOne(
    //   { _id: new ObjectID('5eb2e39e16f0ffb99be1fb72') },
    //   (error, user) => {
    //     if (error) {
    //       return console.log('Unable to find');
    //     }
    //     console.log(user);
    //   }
    // );

    // db.collection('users')
    //   .find({ age: 47 })
    //   .toArray((error, users) => {
    //     console.log(users);
    //   });

    // db.collection('users')
    //   .find({ age: 47 })
    //   .count((error, count) => {
    //     console.log(count);
    //   });

    // db.collection('tasks').findOne(
    //   { _id: new ObjectID('5eb2e576b1fd5ebb841dea43') },
    //   (error, task) => {
    //     console.log(task);
    //   }
    // );
    // db.collection('tasks')
    //   .find({ completed: false })
    //   .toArray((error, tasks) => {
    //     console.log(tasks);
    //   });

    // db.collection('users')
    //   .updateOne(
    //     { _id: new ObjectID('5eb2e08477d4abb66e73d8ba') },
    //     {
    //       $inc: {
    //         age: 1,
    //       },
    //     }
    //   )
    //   .then((result) => {
    //     console.log(result);
    //   })
    //   .catch((error) => {
    //     console.log(error);
    //   });
    // db.collection('tasks')
    //   .updateMany(
    //     { completed: false },
    //     {
    //       $set: {
    //         completed: true,
    //       },
    //     }
    //   )
    //   .then((result) => {
    //     console.log(result);
    //   })
    //   .catch((error) => {
    //     console.log(error);
    //   });

    //     db.collection('users')
    //       .deleteMany({ age: 48 })
    //       .then((result) => {
    //         console.log(result);
    //       })
    //       .catch((error) => {
    //         console.log(error);
    //       });
    //   }

    db.collection('tasks')
      .deleteOne({ description: 'do tutorial' })
      .then((result) => {
        console.log(result);
      })
      .catch((error) => {
        console.log(error);
      });
  }
);
