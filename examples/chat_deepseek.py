"""
调用 DeepSeek 大模型的示例（DeepSeek 兼容 OpenAI SDK）。

运行前准备：
1. 复制 .env.example 为 .env 并填入 DEEPSEEK_API_KEY，
   或在 Codespaces 里用 Secrets 设置 DEEPSEEK_API_KEY（更安全）。
2. 运行：python examples/chat_deepseek.py
"""

import os

from dotenv import load_dotenv
from openai import OpenAI

# 加载 .env 中的环境变量（如果文件存在）
load_dotenv()

api_key = os.getenv("DEEPSEEK_API_KEY")
base_url = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com")

if not api_key:
    raise SystemExit("未找到 DEEPSEEK_API_KEY，请在 .env 或 Codespaces Secrets 中设置。")

# DeepSeek 兼容 OpenAI 接口，只需把 base_url 指向 DeepSeek
client = OpenAI(api_key=api_key, base_url=base_url)

messages = [
    {"role": "system", "content": "你是一个乐于助人的中文助手。"},
    {"role": "user", "content": "用一句话介绍一下你自己。"},
]

print("===== 普通输出 =====")
resp = client.chat.completions.create(
    model="deepseek-chat",
    messages=messages,
    stream=False,
)
print(resp.choices[0].message.content)

print("\n===== 流式输出 =====")
stream = client.chat.completions.create(
    model="deepseek-chat",
    messages=messages,
    stream=True,
)
for chunk in stream:
    delta = chunk.choices[0].delta.content
    if delta:
        print(delta, end="", flush=True)
print()
