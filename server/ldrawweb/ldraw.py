# -*- coding: utf-8 -*-

"""
    ldrawweb.ldraw
    ~~~~~~~~~~~~~~

    Provides basic parsing and validation for LDraw files.

    Copyright (c) 2013 Park "segfault" Joon-Kyu <segfault87@gmail.com>
"""

from ldrawweb.util import str2int as int_


__all__ = ['MIME_TYPE', 'MIME_TYPES', 'ValidationError', 'validate']


MIME_TYPE = 'application/x-ldraw'
MIME_TYPES = ('application/x-ldraw', 'application/x-multi-part-ldraw')
LINE_TYPES = ('0', '1', '2', '3', '4', '5')
LINE_TYPE_PARAMS = {
    '1': [int_, float, float, float, float, float, float, float, float,
          float, float, float, float, str],
    '2': [int_, float, float, float, float, float, float],
    '3': [int_, float, float, float, float, float, float, float, float,
          float],
    '4': [int_, float, float, float, float, float, float, float, float,
          float, float, float, float],
    '5': [int_, float, float, float, float, float, float, float, float,
          float, float, float, float]
}


def check_params(shards, type_):
    for value, type in zip(shards, type_):
        try:
            type(value)
        except ValueError:
            raise ValidationError('Invalid value %s. %r expected.' %
                                  (value, type))


class ValidationError(Exception):
    pass


def validate_line_0(line, context):
    try:
        _, line = line.split(None, 1)
    except ValueError:
        return
    if not hasattr(context, 'desc'):
        context.desc = line
    shards = line.split(None, 1)
    if len(shards) > 1:
        cmd, arg = shards
        cmd = cmd.lower()
        if cmd == 'bfc':
            if not arg.lower() in ('certify ccw',
                                   'certify cw',
                                   'certify invertnext',
                                   'certify',
                                   'certify noclip',
                                   'certify clip',
                                   'nocertify',
                                   'invertnext',
                                   'ccw',
                                   'cw',
                                   'noclip',
                                   'clip'):
                raise ValidationError('Invalid BFC statement')
        elif cmd == 'name:':
            context.name = arg
        elif cmd == 'author:':
            context.author = arg


def validate_line_1(line, context):
    shards = line.split(None, 14)
    if len(shards) < 15:
        raise ValidationError('Not enough arguments')
    check_params(shards[1:], LINE_TYPE_PARAMS['1'])


def validate_line_2(line, context):
    shards = line.split()
    if len(shards) < 8:
        raise ValidationError('Not enough arguments')
    check_params(shards[1:], LINE_TYPE_PARAMS['2'])


def validate_line_3(line, context):
    shards = line.split()
    if len(shards) < 11:
        raise ValidationError('Not enough arguments')
    check_params(shards[1:], LINE_TYPE_PARAMS['3'])


def validate_line_4(line, context):
    shards = line.split()
    if len(shards) < 14:
        raise ValidationError('Not enough arguments')
    check_params(shards[1:], LINE_TYPE_PARAMS['4'])


def validate_line_5(line, context):
    shards = line.split()
    if len(shards) < 14:
        raise ValidationError('Not enough arguments')
    check_params(shards[1:], LINE_TYPE_PARAMS['5'])


VALIDATORS = {
    '0': validate_line_0,
    '1': validate_line_1,
    '2': validate_line_2,
    '3': validate_line_3,
    '4': validate_line_4,
    '5': validate_line_5
}


class SimpleContext(object):
    pass


def validate(stream):
    """Validate the LDraw file"""
    context = SimpleContext()
    for lineno, line in enumerate(stream):
        shards = line.split()
        if len(shards) == 0:
            continue
        if not shards[0] in LINE_TYPES:
            raise ValidationError('Unknown line type %s' % shards[0])
        try:
            VALIDATORS[shards[0]](line.strip(), context)
        except ValidationError, e:
            ex = ValidationError('In line %d: %s' % (lineno + 1,
                                                     e.message))
            ex.line = line.strip()
            ex.lineno = lineno + 1
            raise ex
    if not hasattr(context, 'desc'):
        raise ValidationError('Required metadata `description` is missing.')
    if not hasattr(context, 'name'):
        raise ValidationError('Required metadata `name` is missing.')
    if not hasattr(context, 'author'):
        raise ValidationError('Required metadata `author` is missing.')


if __name__ == '__main__':
    import sys
    if len(sys.argv) == 1:
        print 'usage: %s <files>' % sys.argv[0]
        sys.exit(1)
    for file in sys.argv[1:]:
        print 'validating file %s...' % file
        with open(file) as f:
            try:
                validate(f)
            except ValidationError, e:
                print 'validation failed: %s' % e
                if hasattr(e, 'line'):
                    print 'the following line is:'
                    print e.line
                sys.exit(1)
