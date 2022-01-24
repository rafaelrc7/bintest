.PHONY: all clean

TARGET = bintest

all: $(TARGET)

bintest: main.o

CC = gcc
CFLAGS  += -g -O0 -Wall -Wextra -pedantic
LDFLAGS +=

SRCEXT = c
OBJEXT = o
DEPEXT = d

SRCDIR = src
OBJDIR = obj
DEPDIR = $(OBJDIR)/dep

## AUTO ##

VPATH  = $(SRCDIR):$(OBJDIR)

SRC = $(wildcard $(SRCDIR)/*.$(SRCEXT))
OBJ = $(SRC:$(SRCDIR)/%.$(SRCEXT)=$(OBJDIR)/%.$(OBJEXT))
DEP = $(OBJ:$(OBJDIR)/%.$(OBJEXT)=$(DEPDIR)/%.$(DEPEXT))

$(TARGET):
	$(CC) -o $@ $^ $(LDFLAGS)

$(DEPDIR)/%.$(DEPEXT): $(SRCDIR)/%.$(SRCEXT) | $(DEPDIR)
	@$(CC) $< -MM -MT $(@:$(DEPDIR)/%.$(DEPEXT)=$(OBJDIR)/%.$(OBJEXT)) >$@

-include $(DEP)

$(OBJDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(SRCEXT) | $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c $<

$(OBJDIR) $(DEPDIR):
	mkdir -p $@

clean:
	rm -r $(TARGET) $(OBJDIR)

