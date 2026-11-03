"""공용 채점 도구 단위 테스트:  python3 -m unittest discover -s lib/grading"""
import unittest
from datetime import datetime

import cron
import policy

KST = cron.KST


class WildTest(unittest.TestCase):
    def test_star_question(self):
        self.assertTrue(policy.wild('s3:Get*', 's3:GetObject'))
        self.assertTrue(policy.wild('arn:aws:s3:::b/?.csv', 'arn:aws:s3:::b/a.csv'))
        self.assertFalse(policy.wild('arn:aws:s3:::b/?.csv', 'arn:aws:s3:::b/ab.csv'))

    def test_brackets_are_literal(self):   # fnmatch 와 다른 점
        self.assertFalse(policy.wild('arn:aws:s3:::[ab]', 'arn:aws:s3:::a'))
        self.assertTrue(policy.wild('arn:aws:s3:::[ab]', 'arn:aws:s3:::[ab]'))

    def test_action_case(self):
        self.assertTrue(policy.wild('S3:getobject', 's3:GetObject', ignore_case=True))
        self.assertFalse(policy.wild('arn:aws:s3:::Bucket', 'arn:aws:s3:::bucket'))


class DecideTest(unittest.TestCase):
    B = 'arn:aws:s3:::reports'

    def test_allow_and_implicit(self):
        doc = {'Statement': [{'Effect': 'Allow', 'Action': 's3:GetObject', 'Resource': f'{self.B}/*'}]}
        self.assertEqual(policy.decide([doc], 's3:GetObject', f'{self.B}/a.csv'), 'allow')
        self.assertEqual(policy.decide([doc], 's3:PutObject', f'{self.B}/a.csv'), 'implicit')
        self.assertEqual(policy.decide([doc], 's3:GetObject', 'arn:aws:s3:::other/a.csv'), 'implicit')

    def test_explicit_deny_wins(self):
        docs = [{'Statement': {'Effect': 'Allow', 'Action': 's3:*', 'Resource': '*'}},
                '{"Statement": [{"Effect": "Deny", "Action": ["s3:Delete*", "s3:Put*"], "Resource": "*"}]}']
        self.assertEqual(policy.decide(docs, 's3:GetObject', f'{self.B}/a'), 'allow')
        self.assertEqual(policy.decide(docs, 's3:DeleteObject', f'{self.B}/a'), 'deny')

    def test_not_action_not_resource(self):
        doc = {'Statement': [{'Effect': 'Allow', 'NotAction': 'iam:*', 'NotResource': 'arn:aws:s3:::secret*'}]}
        self.assertTrue(policy.allowed([doc], 'ec2:RunInstances', '*'))
        self.assertFalse(policy.allowed([doc], 'iam:CreateUser', '*'))
        self.assertFalse(policy.allowed([doc], 's3:GetObject', 'arn:aws:s3:::secret-x/a'))

    def test_conditions(self):
        st = lambda c: [{'Statement': [{'Effect': 'Deny', 'Action': '*', 'Resource': '*', 'Condition': c}]}]  # noqa: E731
        region = st({'StringNotEquals': {'aws:RequestedRegion': 'ap-northeast-2'}})
        self.assertEqual(policy.decide(region, 'ec2:RunInstances', ctx={'aws:RequestedRegion': 'us-east-1'}), 'deny')
        self.assertEqual(policy.decide(region, 'ec2:RunInstances', ctx={'aws:RequestedRegion': 'ap-northeast-2'}), 'implicit')
        # 부정 연산자는 키가 없으면 해당(True), 긍정 연산자는 해당 안 함
        self.assertEqual(policy.decide(region, 'iam:CreateRole', ctx={}), 'deny')
        like = st({'StringLike': {'ec2:InstanceType': ['p*', 'g*']}})
        self.assertEqual(policy.decide(like, 'ec2:RunInstances', ctx={'ec2:InstanceType': 'g5.xlarge'}), 'deny')
        self.assertEqual(policy.decide(like, 'ec2:RunInstances', ctx={'ec2:InstanceType': 'm7g.large'}), 'implicit')
        self.assertEqual(policy.decide(like, 'ec2:DescribeInstances', ctx={}), 'implicit')
        ifx = st({'StringEqualsIfExists': {'sts:ExternalId': 'x'}})
        self.assertEqual(policy.decide(ifx, 'sts:AssumeRole', ctx={}), 'deny')
        null = st({'Null': {'aws:MultiFactorAuthAge': 'true'}})
        self.assertEqual(policy.decide(null, 's3:GetObject', ctx={}), 'deny')
        self.assertEqual(policy.decide(null, 's3:GetObject', ctx={'aws:MultiFactorAuthAge': 30}), 'implicit')
        num = st({'NumericGreaterThan': {'s3:max-keys': 10}})
        self.assertEqual(policy.decide(num, 's3:ListBucket', ctx={'s3:max-keys': 50}), 'deny')
        self.assertEqual(policy.decide(num, 's3:ListBucket', ctx={'s3:max-keys': 5}), 'implicit')
        with self.assertRaises(ValueError):
            policy.decide(st({'DateGreaterThan': {'aws:CurrentTime': '2026-01-01'}}), 's3:GetObject', ctx={'aws:CurrentTime': 'x'})


class ScpTest(unittest.TestCase):
    FULL = {'Statement': [{'Effect': 'Allow', 'Action': '*', 'Resource': '*'}]}
    SEOUL = {'Statement': [{'Effect': 'Deny', 'NotAction': ['iam:*', 'sts:*'], 'Resource': '*',
                            'Condition': {'StringNotEquals': {'aws:RequestedRegion': 'ap-northeast-2'}}}]}

    def test_levels(self):
        levels = [[self.FULL], [self.FULL, self.SEOUL], [self.FULL]]
        us = {'aws:RequestedRegion': 'us-east-1'}
        self.assertEqual(policy.scp_decide(levels, 'ec2:RunInstances', us), 'deny')
        self.assertEqual(policy.scp_decide(levels, 'iam:CreateRole', us), 'allow')
        self.assertEqual(policy.scp_decide(levels, 'ec2:RunInstances', {'aws:RequestedRegion': 'ap-northeast-2'}), 'allow')
        # 중간 단계에 Allow 가 없으면(FullAWSAccess 를 뗌) 전부 막힌다
        self.assertEqual(policy.scp_decide([[self.FULL], [self.SEOUL], [self.FULL]], 'iam:CreateRole', us), 'deny')


class TrustTest(unittest.TestCase):
    def test_principals(self):
        doc = {'Statement': [{'Effect': 'Allow', 'Principal': {'AWS': ['arn:aws:iam::111122223333:root', '444455556666']},
                              'Action': 'sts:AssumeRole'},
                             {'Effect': 'Allow', 'Principal': '*', 'Action': ['sts:*']},
                             {'Effect': 'Allow', 'Principal': {'Service': 'ec2.amazonaws.com'}, 'Action': 'sts:TagSession'}]}
        got = [(k, policy.account_of(v)) for k, v, _ in policy.assume_principals(doc)]
        self.assertEqual(got, [('AWS', '111122223333'), ('AWS', '444455556666'), ('AWS', '*')])


class CronTest(unittest.TestCase):
    def kst(self, times):
        return [(t.month, t.day, t.hour, t.minute) for t in times]

    def test_daily_utc(self):
        t = cron.fires('cron(0 18 * * ? *)')
        self.assertTrue(all((x.hour, x.minute) == (3, 0) for x in t))
        self.assertEqual(len({x.date() for x in t}), len(t))

    def test_last_day_is_first_in_kst(self):
        self.assertEqual(self.kst(cron.fires('cron(0 18 L * ? *)')), [(1, 1, 3, 0), (2, 1, 3, 0)])
        self.assertEqual(self.kst(cron.fires('cron(0 18 1 * ? *)')), [(1, 2, 3, 0), (2, 2, 3, 0)])
        self.assertEqual(self.kst(cron.fires('cron(0 3 1 * ? *)', tz='Asia/Seoul')), [(1, 1, 3, 0), (2, 1, 3, 0)])

    def test_weekdays_shift(self):
        t = cron.fires('cron(30 18 ? * SUN-THU *)')
        self.assertEqual({x.isoweekday() for x in t}, {1, 2, 3, 4, 5})   # 한국 월~금
        t = cron.fires('cron(30 18 ? * 2-6 *)')                           # MON-FRI(UTC) = 한국 화~토
        self.assertEqual({x.isoweekday() for x in t}, {2, 3, 4, 5, 6})

    def test_invalid(self):
        for e in ('0 18 * * ? *', 'cron(0 18 * * * *)', 'cron(0 18 ? * ? *)', 'cron(0 25 * * ? *)'):
            with self.assertRaises(ValueError):
                cron.parse(e)

    def test_describe(self):
        t = [datetime(2027, 1, 1, 3, tzinfo=KST), datetime(2027, 2, 1, 3, tzinfo=KST)]
        self.assertEqual(cron.describe(t), '1월 1일 03:00, 2월 1일 03:00')
        self.assertEqual(cron.describe([]), '안 돌아요')


if __name__ == '__main__':
    unittest.main()
