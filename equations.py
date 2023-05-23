"""
A queima do combustível no interior da câmara de combustão,
juntamente com o ar pré-aquecido transfere energia para os gases
e para o metal dos tubos de água por convecção e radiação
"""

#  conservação de massa:
m = {}
m['g'] = m['fuel'] + m['ar,out']

#  conservação de energia:
q = {}
h = {}
T = {}
cp = {}
alpha = {}

PCI = 8223  # kJ/kg

q['fuel'] = q['fuel']*PCI

h['ar,out'] = cp['ar,out'] * T['ar,out'] - cp['ref'] * T['ref']
q['ar,out'] = m['ar,out'] * h['ar,out']

q['rad,F'] = alpha['rad,f'] * (T['for']**4 - T['metal']**4)
q['conv,F'] = alpha['conv,f'] * (T['for'] - T['metal'])

h['g'] = cp['g'] * T['g'] - cp['ref'] * T['ref']
q['g'] = m['g']*h['g']

T['ad'] = (q['fuel'] + q['ar,out'])/(m['g']*cp['ad'])
T['for'] = (T['g'] + T['ad'])/2
