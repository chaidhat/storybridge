require('dotenv').config({ path: `../.env.${process.env.NODE_ENV}` });
const Db = require('./database');
const CourseElements = require('./courseElements');
const { Configuration, OpenAIApi } = require("openai");

const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);

// recursively parses columns to find all relavant text
function parseColumn(columnObj) {
    let children = columnObj.children;
    let textOutput = "";
    for (let i = 0; i < children.length; i++) {
        switch(children[i].widgetType) {
            case "column":
                textOutput += parseColumn(children[i]) + "\n";
                break;
            case "text":
                textOutput += children[i].text + "\n";
                break;
        }
    }
    return textOutput;
}

module.exports.getAiCourseElementSummary = getAiCourseElementSummary;
async function getAiCourseElementSummary(token, courseElementId) {
    let courseElement = await CourseElements.getCourseElement (token, courseElementId);
    let rootColumn = JSON.parse(decodeURI(courseElement[0].data));
    let prompt = parseColumn(rootColumn);
    console.log(prompt)

    try {
        const response = await openai.createChatCompletion({
            model: "gpt-3.5-turbo-16k",
            messages: [
                {
                    "role": "system",
                    "content": "Very briefly write a summary for this section in the language it was written in. Write it out as very short bullet points."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            temperature: 0,
            max_tokens: 500,
            top_p: 1,
            frequency_penalty: 0,
            presence_penalty: 0
        });
        let result = response.data.choices[0].message;
        return result.content;

    } catch (error) {
        console.log(error.message);
        return "An error occured. This page may be too large -- try split the page into smaller pages!";
    }
}

module.exports.askAiCourseElementQuestion = askAiCourseElementQuestion;
async function askAiCourseElementQuestion(token, question, courseElementId) {
    let courseElement = await CourseElements.getCourseElement (token, courseElementId);
    let rootColumn = JSON.parse(decodeURI(courseElement[0].data));
    let data = parseColumn(rootColumn);

    try {
        const response = await openai.createChatCompletion({
            model: "gpt-3.5-turbo-16k",
            messages: [
                {
                    "role": "system",
                    "content": "The user gives you a section of an online course and then follows up with question. Answer the question using only the information that was provided and nothing more. Keep it very brief."
                },
                {
                    "role": "user",
                    "content": data
                },
                {
                    "role": "user",
                    "content": question
                }
            ],
            temperature: 0,
            max_tokens: 500,
            top_p: 1,
            frequency_penalty: 0,
            presence_penalty: 0
        });
        let result = response.data.choices[0].message;
        return result.content;

    } catch (error) {
        console.log(error.message);
        return "An error occured. This page may be too large -- try split the page into smaller pages!";
    }
}