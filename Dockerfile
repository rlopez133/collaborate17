# ORACLE AUTOMATED STRESS/SYSTEM TESTING (OAST)
# --------------------------------------------
#
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) RHEL7_oracle12c_oast_full_kit.tar
# 
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Run:
# $ docker build -t oracle/oast:12c .

# Maintainer
# ----------
MAINTAINER Roger Lopez <rlopez@redhat.com>

# Pull base image
# ---------------
FROM rhel7

# Environment variables required for this build (do NOT change)
# ------------------------------------------------------------
ENV MOUNTPT=/perf1
ENV ORACLE_HOME=/oracle/app/oracle/product/12/dbhome_1
ENV ORACLE_SID=oast1
ENV PATH=$PATH:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/X11R6/bin:/root/bin:$ORACLE_HOME/bin:$ORACLE_HOME/OPatch
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib


# Install packages
# ----------------
RUN yum -y update && \
yum install -y \
binutils \
compat-libstdc++-33.i686 \
compat-libstdc++-33.x86_64 \
elfutils \
elfutils-libelf-devel \
gcc \
gcc-c++ \
glibc.i686 \
glibc.x86_64 \
glibc-common \
glibc-devel.i686 \
glibc-devel.x86_64 \
ksh \
libaio.i686 \
libaio.x86_64 \
libaio-devel.x86_64 \
libgcc.i686 \
libgcc.x86_64 \
libstdc++.i686 \
libstdc++.x86_64 \
libstdc++-devel.x86_64 \
make \
numactl-devel \
sysstat \
tar && \
yum clean all

# Copy & Extract OAST Kit
# -----------------------
RUN curl -o /RHEL7_oracle12c_oast_full_kit.tar \
http://example.com/RHEL7_oracle12c_oast_full_kit.tar \
&& tar -xpf /RHEL7_oracle12c_oast_full_kit.tar \
&& rm /RHEL7_oracle12c_oast_full_kit.tar

# Create Oracle user and dba group
# --------------------------------
RUN groupadd -g 1001 dba \
&& adduser -d /oracle -m -g dba -G sys -u 1001 oracle

# Copy & set kernel parameters and security limits
# ------------------------------------------------
RUN curl -o /sysctl_and_securitylimits_parameters.sh \
http://example.com/sysctl_and_securitylimits_parameters.sh \
&& chmod 755 /sysctl_and_securitylimits_parameters.sh \
&& ./sysctl_and_securitylimits_parameters.sh \ 
&& rm -f /sysctl_and_securitylimits_parameters.sh


# Create dir and set permissions
# -----------------------------
RUN mkdir -p $MOUNTPT/server \
&& chown -R oracle.dba $MOUNTPT

VOLUME ["$MOUNTPT"]

USER oracle
WORKDIR /oracle/oast/home/
