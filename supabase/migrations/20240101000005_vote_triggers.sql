-- Increment/decrement vote counter in feature_requests when votes are added/removed.
-- Mirrors Firebase's incrementVoteCounter / decrementVoteCounter Cloud Functions.

CREATE OR REPLACE FUNCTION public.increment_feature_votes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.feature_requests
  SET votes = votes + 1,
      last_update_date = now()
  WHERE id = NEW.feature_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_feature_vote_added ON public.feature_votes;
CREATE TRIGGER on_feature_vote_added
  AFTER INSERT ON public.feature_votes
  FOR EACH ROW EXECUTE PROCEDURE public.increment_feature_votes();

CREATE OR REPLACE FUNCTION public.decrement_feature_votes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.feature_requests
  SET votes = GREATEST(0, votes - 1),
      last_update_date = now()
  WHERE id = OLD.feature_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_feature_vote_removed ON public.feature_votes;
CREATE TRIGGER on_feature_vote_removed
  AFTER DELETE ON public.feature_votes
  FOR EACH ROW EXECUTE PROCEDURE public.decrement_feature_votes();
