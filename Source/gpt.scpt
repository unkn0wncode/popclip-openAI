function run(input, parameters, model) {
    try {
      const userText = input ? input : "This is sample text for testing";
      const apiKey = parameters ? parameters : "";
      if (!apiKey) {
        showErrorDialog("Error: API key is not set" );
        return "Error: API key is not set";
      }
      
      const prompt = getUserInput();
      if (!prompt) return null;

      const response = queryOpenAI(prompt, userText, apiKey, model);
      
      showResponseDialog(response);
      
      return response;
    } catch (error) {
      showErrorDialog(`Error: ${error.message}`);
      return `Error: ${error.message}`;
    }
  }
  
  function getUserInput() {
    try {
      const app = Application.currentApplication();
      app.includeStandardAdditions = true;
      
      const result = app.displayDialog("Enter the data you want to send:", {
        defaultAnswer: "",
        buttons: ["Cancel", "OK"],
        defaultButton: "OK",
        cancelButton: "Cancel"
      });
      
      return result.textReturned;
    } catch (error) {
      return null;
    }
  }
  
  function sanitizeString(str) {
      return str.replace(/[\u200B-\u200D\uFEFF\uFFFC]/g, "");
  }
  
  function shellQuote(str) {
      return "'" + str.replace(/'/g, "'\\''") + "'";
  }
  
  function queryOpenAI(prompt, userInput, apiKey, model) {
    try {
      const app = Application.currentApplication();
      app.includeStandardAdditions = true;
  
      const url = "https://api.openai.com/v1/chat/completions";
      const dataPayload = {
          model: model,
          messages: [
              { role: "system", content: prompt },
              { role: "user", content: userInput }
          ]
      };
      
      const stringifiedPayload = JSON.stringify(dataPayload);
   
      const fullShellCommand = `printf "%s" ${shellQuote(stringifiedPayload)} | curl -s -X POST "${url}" \\
        -H "Authorization: Bearer ${apiKey}" \\
        -H "Content-Type: application/json" \\
        --data-binary @-`;
  
      const response = app.doShellScript(fullShellCommand);
      console.log("API Response:", response);
  
      const responseObject = JSON.parse(response);
  
      if (responseObject.error) {
        throw new Error(`OpenAI API error: ${responseObject.error.message}`);
      }
  
      return responseObject.choices[0].message.content.trim();
    } catch (error) {
      console.log("Error during OpenAI query or processing:", error.message);
      throw new Error(`Failed to connect to OpenAI server or process response: ${error.message}`);
    }
  }
  
  function showResponseDialog(content) {
    try {
      const app = Application.currentApplication();
      app.includeStandardAdditions = true;
      
      const safeContent = content.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
      
      const result = app.displayDialog(`Response: ${safeContent}`, {
        buttons: ["Copy", "OK"],
        defaultButton: "OK"
      });
      
      if (result.buttonReturned === "Copy") {
        app.setTheClipboardTo(content);
      }
    } catch (error) {
      throw new Error(`Failed to show response dialog: ${error.message}`);
    }
  }
  
  function showErrorDialog(message) {
    try {
      const app = Application.currentApplication();
      app.includeStandardAdditions = true;
      
      app.displayDialog(message, {
        buttons: ["OK"],
        defaultButton: "OK",
        withIcon: "stop"
      });
    } catch (error) {
      console.log(`Error showing error dialog: ${error.message}`);
    }
  }
  
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = { run };
  }
