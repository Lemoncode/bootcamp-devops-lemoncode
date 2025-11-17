const Topic = require("./models/topics");
const express = require("express"),
  mongoose = require("mongoose"),
  bodyParser = require("body-parser"),
  cors = require("cors"),
  app = express();

//configure CORS
app.use(cors());

//configure app to use body-parser
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

const port = process.env.PORT || 8080;

const delay = () =>
  new Promise((res) => {
    setTimeout(() => {
      res();
    }, 1000);
  });

const connect = async () => {
  await delay();
  try {
    await mongoose.connect("mongodb://mongodb:27017/test");
    console.log("connected to test");
  } catch (error) {
    console.error(error);
  }
};

//Routes
const router = express.Router();

router.post("/topics", async (req, res) => {
  console.log("[POST] Topics");

  const topic = new Topic();
  topic.name = req.body.name;

  try {
    const result = await topic.save();
    console.log(result);
    res.send(result);
  } catch (error) {
    console.error(error);
    res.send(JSON.parse(error));
  }
});

router.get("/topics", async (_, res) => {
  console.log("[GET] Topics");
  console.log(Topic);

  try {
    const collection = await Topic.find({});
    const topics = collection.map((t) => ({
      id: t._id.toString(),
      name: t.name,
    }));
    res.send(topics);
  } catch (error) {
    console.error(err);
    res.send(JSON.parse(error));
  }
});

router.delete("/topics/:id", async (req, res) => {
  console.log("[DELETE] Topic by ID:", req.params.id);

  try {
    const result = await Topic.findByIdAndDelete(req.params.id);
    if (!result) {
      return res.status(404).send({ error: "Topic not found" });
    }
    console.log("Deleted topic:", result);
    res.send({ message: "Topic deleted successfully", id: req.params.id });
  } catch (error) {
    console.error(error);
    res.status(400).send({ error: error.message });
  }
});

//all routes will be prefixed with /api
app.use("/api", router);

//start the server
app.listen(port, async () => {
  console.log(`Server up and running on port ${port}`);
  await connect();
});
