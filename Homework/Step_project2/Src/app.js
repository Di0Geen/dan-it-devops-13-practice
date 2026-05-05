const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
    res.send("Hello from Step Project 2 Node.js app!");
});

app.get("/health", (req, res) => {
    res.json({
        status: "OK",
        message: "App is running"
    });
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});