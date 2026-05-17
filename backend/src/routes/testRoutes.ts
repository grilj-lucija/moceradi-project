import express from "express";
import controller from "../controllers/testController";

const router = express.Router();

router.get("/", async (req, res) => {
    await controller.test(req, res);
})

router.post("/", async (req, res) => {
    await controller.test(req, res);
})

export default router;