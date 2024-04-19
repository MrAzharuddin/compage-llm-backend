from functools import wraps
import time

from cassandra.cluster import Cluster # pylint: disable = no-name-in-module
from cassandra.policies import DCAwareRoundRobinPolicy, RetryPolicy # pylint: disable = no-name-in-module
from cassandra.cqlengine.connection import register_connection, set_default_connection # pylint: disable = no-name-in-module

KEYSPACE = "backend_llm"

class CustomRetryPolicy(RetryPolicy):
    """Custom retry policy to retry on all errors."""
    def __init__(self, max_retries=5, delay=3000):
        self.max_retries = max_retries
        self.delay = delay

    def on_read_timeout(self, retry_num):
        """Retry on read timeout."""
        if retry_num < self.max_retries:
            return self.delay
        return None

    def on_write_timeout(self, retry_num):
        """Retry on write timeout."""
        if retry_num < self.max_retries:
            return self.delay
        return None

    def on_unavailable(self, retry_num):
        """Retry on unavailable."""
        if retry_num < self.max_retries:
            return self.delay
        return None


def retry_on_failure(max_retries=3, delay=5):
    """
    A function decorator that retries the execution of a function in case of failure up to a maximum number of retries.
    It takes the maximum number of retries and the delay between retries as parameters.
    Returns a decorator function that wraps the provided function and handles retries.
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            retries = 0
            while retries < max_retries:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    print(f"Failed to execute {func.__name__}: {e}")
                    retries += 1
                    if retries < max_retries:
                        print(f"Retrying in {delay} seconds...")
                        time.sleep(delay)
            raise Exception(f"Failed to execute {func.__name__} after {max_retries} attempts.")
        return wrapper
    return decorator


@retry_on_failure()
def get_session():
    """A function to get the cluster and establish a session to a specific keyspace."""
    cluster = Cluster(
        ["127.0.0.1"],
        port=9042,
        load_balancing_policy=DCAwareRoundRobinPolicy(local_dc="datacenter1"),
        protocol_version=4,
        default_retry_policy=CustomRetryPolicy()
    )
    session = cluster.connect()
    session.execute(f"CREATE KEYSPACE IF NOT EXISTS {KEYSPACE} WITH REPLICATION = {{'class' : 'SimpleStrategy', 'replication_factor' : 1}}")
    register_connection(str(session), session=session)
    set_default_connection(str(session))
    session = cluster.connect()
    session.execute(f"CREATE KEYSPACE IF NOT EXISTS {KEYSPACE} WITH REPLICATION = {{'class' : 'SimpleStrategy', 'replication_factor' : 1}}")
    return session
