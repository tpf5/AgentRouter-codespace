"""
调用 Anthropic Claude 大模型的示例。

运行前准备：
1. 在 .env 或 Codespaces Secrets 中设置 ANTHROPIC_API_KEY。
2. 运行：python examples/chat_anthropic.py
"""

import os

from anthropic import Anthropic
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("ANTHROPIC_API_KEY")
if not api_key:
    raise SystemExit("未找到 ANTHROPIC_API_KEY，请在 .env 或 Codespaces Secrets 中设置。")

client = Anthropic(api_key=api_key)

# 使用最新的 Claude 模型
resp = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system="你是一个乐于助人的中文助手。",
    messages=[
        {"role": "user", "content": "用一句话介绍一下你自己。"},
    ],
)

print(resp.content[0].text)
