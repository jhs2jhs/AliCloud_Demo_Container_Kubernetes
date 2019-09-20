FROM jupyter/minimal-notebook:latest
RUN pip install aliyun-python-sdk-imagesearch 
RUN pip install pillow
RUN pip install scrapy
RUN git clone https://github.com/jianhuashao/AlibabaCloud_ImageSearch_Demo_py2.git /home/jovyan/demo/AliCloud_Demo_ImageSearch/
RUN ls -lhs /home/jovyan/demo/
RUN cd /home/jovyan/demo/AliCloud_Demo_ImageSearch && python3 downloader_aliexpress.py --limit 20
RUN cd /home/jovyan/demo/AliCloud_Demo_ImageSearch && touch my_git_pull_timestamp.txt

