FROM debian:slim
MAINTAINER liu1084@gmail.com
ENV LANG="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive" \
    TZ="Asia/Shanghai"
ENV MINI_CONDA_HOME=/root/miniconda3
WORKDIR ${MINI_CONDA_HOME}/jupyter
SHELL ["/bin/bash", "-ec"]
ADD conf/resolv.conf /etc/resolv.conf
ADD conf/sources.list /etc/apt/sources.list
ADD requirements.txt .
ADD software/miniconda.sh .
COPY docker-entrypoint.sh ${MINI_CONDA_HOME}/docker-entrypoint.sh
USER root
RUN apt update -y && apt upgrade -y \
    && apt install curl \
    && curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ${MINI_CONDA_HOME}/miniconda.sh \
    && bash ${MINI_CONDA_HOME}/miniconda.sh -b -u -p ${MINI_CONDA_HOME} \
    && ${MINI_CONDA_HOME}/bin/conda init bash && rm -rf ${MINI_CONDA_HOME}/miniconda.sh \
    && echo "alias ll='ls --color=auto -la'" >> ~/.bashrc \
    && . ~/.bashrc \
    && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/linux-64/ \
    && conda config --set show_channel_urls yes \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && ln -sf /bin/bash /bin/sh \
    && echo ${TZ} > /etc/timezone \
    && chmod a+x ${MINI_CONDA_HOME}/docker-entrypoint.sh \
    && conda create -n jupyterlab -y python=3.10 \
    && conda install -n jupyterlab -y pip && conda activate jupyterlab \
	&& pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && pip3 install -r requirements.txt \
    && rm -f requirements.txt \
    && apt clean autoclean && apt autoremove --yes \
    && pip3 cache purge

COPY conf/jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888
VOLUME ["/root/miniconda3/jupyter/notebooks", "/root/.jupyter/"]
ENTRYPOINT ["/root/miniconda3/docker-entrypoint.sh"]
CMD ["jupyter"]
