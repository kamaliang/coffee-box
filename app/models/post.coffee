mongoose = require 'mongoose'
Schema = mongoose.Schema

CommentSchema = (require './comment').schema

PostSchema = new Schema
  title:     { type: String, required: true }
  body:      { type: String }
  slug:      { type: String, required: true }
  comments:  [CommentSchema]
  tags:      [String]
  createdAt: { type: Date,   required: true }
  updatedAt: { type: Date,   required: true }

Post = mongoose.model 'Post', PostSchema

module.exports =
  schema: PostSchema
  model:  Post
