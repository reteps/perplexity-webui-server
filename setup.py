from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="perplexity_webui_server",
    version="0.1",
    description="A python server that runs the perplexity.ai webui as a webserver",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/reteps/perplexity-webui-langchain",
    scripts=['perplexity_webui_server/perplexity_webui_server'],
    packages=find_packages(),
    install_requires=[
        "perplexity_webui_langchain@git+https://github.com/reteps/perplexity-webui-langchain.git",
        "langchain-openai-api-bridge",
        "fastapi",
        "python-dotenv",
        "uvicorn",
        "langgraph",
    ],
)
