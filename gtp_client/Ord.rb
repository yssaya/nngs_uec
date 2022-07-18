unless "a".respond_to?:ord  # For Ruby1.8 and earlier
    class String
        def ord
            self[0]
        end
    end
    class Integer
        def ord
            self
        end
    end
end
