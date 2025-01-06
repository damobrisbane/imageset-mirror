#!/usr/bin/python

import sys, json
from pprint import pprint as pp

"""
{
  "subs_csv": [
    {
      "ocp4y.dmz.lan": {
        "percona-postgresql-operator-certified@preview": "2.3.1",
        "percona-postgresql-operator-certified@stable": "2.5.0"
      }
    },
    {
      "ocp4x.dmz.lan": {
        "cert-manager@stable": "1.16.1"
      }
    }
  ]
}

"""

def f2(d):
  """
  ('ocp4y.dmz.lan',
   {'percona-postgresql-operator-certified@preview': '2.3.1',
    'percona-postgresql-operator-certified@stable': '2.5.0'})
  ('ocp4x.dmz.lan', {'cert-manager@stable': '1.16.1'})
  """


def f1(l_cl):
  """
  {'subs_csv': [{'ocp4y.dmz.lan': {'percona-postgresql-operator-certified@preview': '2.3.1',
                                 'percona-postgresql-operator-certified@stable': '2.5.0'}},
              {'ocp4x.dmz.lan': {'cert-manager@stable': '1.16.1'}}]}

  """

  f_op_ch = lambda s:s.split('@')

  d_csv = dict()

  for d in l_cl:
    c = list(d.keys())[0]
    d_csvs = d[c]

    for op_ch,ver in d_csvs.items():
      op, ch = f_op_ch(op_ch)
      d_csv.setdefault(op, { 'channels':dict() } )
      d_csv[op]['channels'].setdefault(ch, list())
      d_csv[op]['channels'][ch].append(ver)

      
  pp(d_csv)

if __name__ == '__main__':
  fn = sys.argv[1]
  j1 = json.load(open(fn, 'r'))

  f1(j1['subs_csv'])
