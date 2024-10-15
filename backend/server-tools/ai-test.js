const { Configuration, OpenAIApi } = require("openai");
const fs = require('fs');

const configuration = new Configuration({
  apiKey: "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",
});
const openai = new OpenAIApi(configuration);

const WORD_SIZE = 2500; // characters

let g_dataset;
let g_unresolved_prompts = 0;

fs.readFile('test-data.json', 'utf8', (err, data) => {
    if (err) {
      console.error(err);
      return;
    }
    const inputDataset = JSON.parse(data);
    g_dataset = inputDataset;

    run(g_dataset);
  });

async function summarize(dataset, i) {
    let prompt = dataset.sectionData[i].elementData;
    // trigger OpenAI completion
  try {
    const response = await openai.createChatCompletion({
        model: "gpt-3.5-turbo-16k",
        messages: [
            {
                "role": "system",
                "content": "Very briefly write a summary for this section. Write it out as very short bullet points."
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
    let res = response.data.choices[0].message;
    dataset.sectionData[i].summary = res;
    console.log(JSON.stringify(dataset));

    fs.writeFile('output.json', JSON.stringify(dataset), err => {
        if (err) {
          console.error(err);
        }
        // file written successfully
      });
  } catch (error) {
    console.log(error.message);
  }
}

async function run (dataset) {
  try {
    for (let i = 0; i < dataset.sectionData.length; i++) {
        await summarize(dataset, i);
    }
    // ...
  } catch (error) {
    console.log(error.message);
  }
}