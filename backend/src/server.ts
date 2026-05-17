import express, { type Application } from "express";
import testRoute from "./routes/testRoutes";
import foodsRoutes from "./routes/foodsRoutes";
import locationsRoutes from "./routes/locationsRoutes";

const app: Application = express();
const port = process.env.PORT || 3000;

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.use("/", testRoute);
app.use("/foods", foodsRoutes);
app.use("/locations", locationsRoutes);

app.listen(port, () => {
    console.log(`Server started on port ${port}`);
})