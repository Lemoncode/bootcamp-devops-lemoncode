# Using environment variables

Update `my-app/backend/index.js`

```diff
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
+
+router.get("/setup", async (_, res) => {
+ const debug = process.env.DEBUG ?? "no value";
+ res.send({ debug });
+});
+
//all routes will be prefixed with /api
app.use("/api", router);

```

Create `docker-compose.envs.yml`