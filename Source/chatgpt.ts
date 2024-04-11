import axios from "axios";

// our own options
declare type ChatGPTOptions = {
  prompt: string;
  apikey: string;
  model: string;
};

// typescript interfaces for OpenAI API
interface Message {
  role: "user" | "system" | "assistant";
  content: string;
}
interface ResponseData {
  choices: [
    {
      message: Message;
    }
  ];
}
interface Response {
  data: ResponseData;
}

// the main chat action
const chat: ActionFunction<ChatGPTOptions> = async (input, options) => {
  const openai = axios.create({
    baseURL: "https://api.openai.com/v1",
    headers: { Authorization: `Bearer ${options.apikey}` },
  });

  const messages: Message[] = [
    { role: "system", content: options.prompt },
    { role: "user", content: input.text },
  ];
  // send the whole message history to OpenAI
  try {
    const { data }: Response = await openai.post("chat/completions", {
      model: options.model || "gpt-3.5-turbo",
      messages,
    });
    popclip.pasteText(data.choices[0].message.content);
    popclip.showSuccess();
  } catch (e) {
    popclip.showText(getErrorInfo(e));
  }
};

export function getErrorInfo(error: unknown): string {
  if (typeof error === "object" && error !== null && "response" in error) {
    const response = (error as any).response;
    //return JSON.stringify(response);
    return `Message from OpenAI (code ${response.status}): ${response.data.error.message}`;
  } else {
    return String(error);
  }
}

// export the actions
export const actions: Action<ChatGPTOptions>[] = [
  {
    title: "ChatGPT: Custom",
    code: chat,
  },
];
